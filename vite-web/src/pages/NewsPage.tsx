import { useState, useEffect } from 'react';
import { fetchNewsItems, getNewsCategories } from '../services/api';
import type { NewsItem } from '../models/NewsItem';
import NewsCard from '../components/NewsCard';
import './NewsPage.css';

export default function NewsPage() {
  const [newsItems, setNewsItems] = useState<NewsItem[]>([]);
  const [filteredNews, setFilteredNews] = useState<NewsItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [dateFilter, setDateFilter] = useState('all');

  const categories = getNewsCategories();
  
  useEffect(() => {
    const loadNews = async () => {
      setIsLoading(true);
      setError(null);
      
      try {
        const news = await fetchNewsItems(1, selectedCategory);
        setNewsItems(news);
        setFilteredNews(news);
      } catch (err) {
        setError('Không thể tải tin tức. Vui lòng thử lại sau.');
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    
    loadNews();
  }, [selectedCategory]);
  
  useEffect(() => {
    // Apply filters when search query or date filter changes
    applyFilters();
  }, [searchQuery, dateFilter, newsItems]);

  const applyFilters = () => {
    let filtered = [...newsItems];
    
    // Apply search query filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        item => item.title.toLowerCase().includes(query) || 
                item.tags.some(tag => tag.toLowerCase().includes(query))
      );
    }
    
    // Apply date filter
    if (dateFilter !== 'all') {
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      
      filtered = filtered.filter(item => {
        const publishDate = new Date(item.publishDate);
        
        switch (dateFilter) {
          case 'today':
            return publishDate >= today;
          case 'week':
            const weekAgo = new Date(now);
            weekAgo.setDate(weekAgo.getDate() - 7);
            return publishDate >= weekAgo;
          case 'month':
            const monthAgo = new Date(now);
            monthAgo.setMonth(monthAgo.getMonth() - 1);
            return publishDate >= monthAgo;
          default:
            return true;
        }
      });
    }
    
    setFilteredNews(filtered);
  };
  
  const handleCategoryChange = (category: string) => {
    setSelectedCategory(category);
  };
  
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };
  
  const handleDateFilterChange = (filter: string) => {
    setDateFilter(filter);
  };
  
  const handleRefresh = () => {
    const loadNews = async () => {
      setIsLoading(true);
      
      try {
        const news = await fetchNewsItems(1, selectedCategory);
        setNewsItems(news);
        applyFilters();
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    
    loadNews();
  };

  return (
    <div className="news-page">
      <header className="news-header">
        <h1>Tin Tức Phòng Chống Lừa Đảo</h1>
        <p>Cập nhật thông tin mới nhất về các chiêu thức lừa đảo</p>
      </header>
      
      <div className="news-filters">
        <div className="search-bar">
          <input
            type="text"
            placeholder="Tìm kiếm tin tức..."
            value={searchQuery}
            onChange={handleSearchChange}
          />
          <button className="search-button">
            🔍
          </button>
        </div>
        
        <div className="category-filter">
          <button 
            className={selectedCategory === '' ? 'active' : ''}
            onClick={() => handleCategoryChange('')}
          >
            Tất cả
          </button>
          {categories.map((category) => (
            <button
              key={category}
              className={selectedCategory === category ? 'active' : ''}
              onClick={() => handleCategoryChange(category)}
            >
              {category}
            </button>
          ))}
        </div>
        
        <div className="date-filter">
          <button 
            className={dateFilter === 'all' ? 'active' : ''}
            onClick={() => handleDateFilterChange('all')}
          >
            Tất cả
          </button>
          <button 
            className={dateFilter === 'today' ? 'active' : ''}
            onClick={() => handleDateFilterChange('today')}
          >
            Hôm nay
          </button>
          <button 
            className={dateFilter === 'week' ? 'active' : ''}
            onClick={() => handleDateFilterChange('week')}
          >
            Tuần này
          </button>
          <button 
            className={dateFilter === 'month' ? 'active' : ''}
            onClick={() => handleDateFilterChange('month')}
          >
            Tháng này
          </button>
        </div>
      </div>
      
      <div className="refresh-bar">
        <button className="refresh-button" onClick={handleRefresh} disabled={isLoading}>
          {isLoading ? 'Đang tải...' : '↻ Làm mới'}
        </button>
        <span className="result-count">
          Hiển thị {filteredNews.length} tin tức
        </span>
      </div>
      
      {isLoading ? (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Đang tải tin tức...</p>
        </div>
      ) : error ? (
        <div className="error-container">
          <p className="error-message">{error}</p>
          <button onClick={handleRefresh}>Thử lại</button>
        </div>
      ) : filteredNews.length === 0 ? (
        <div className="empty-container">
          <p>Không tìm thấy tin tức phù hợp</p>
        </div>
      ) : (
        <div className="news-grid">
          {filteredNews.map((news, index) => (
            <div key={index} className="news-item-container">
              <NewsCard news={news} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
} 