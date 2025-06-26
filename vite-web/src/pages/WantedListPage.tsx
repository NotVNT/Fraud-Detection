import { useState, useEffect, useCallback } from 'react';
import { fetchWantedPersons, getWantedCategories, getWantedCategoryNames } from '../services/api';
import type { WantedPerson } from '../models/WantedPerson';
import WantedPersonCard from '../components/WantedPersonCard';
import './WantedListPage.css';

export default function WantedListPage() {
  const [wantedPersons, setWantedPersons] = useState<WantedPerson[]>([]);
  const [filteredPersons, setFilteredPersons] = useState<WantedPerson[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState('all');

  const categories = getWantedCategories();
  const categoryNames = getWantedCategoryNames();
  
  useEffect(() => {
    loadWantedPersons();
  }, []);
  
  const applyFilters = useCallback(() => {
    if (!wantedPersons.length) return;
    
    let filtered = [...wantedPersons];
    
    // Apply search query filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        person => 
          person.name.toLowerCase().includes(query) || 
          person.address.toLowerCase().includes(query) || 
          person.crime.toLowerCase().includes(query)
      );
    }
    
    // Apply crime type filter
    if (filterType !== 'all') {
      filtered = filtered.filter(person => {
        const crime = person.crime.toLowerCase();
        
        switch (filterType) {
          case 'financial':
            return crime.includes('tài sản') || 
                  crime.includes('tiền') ||
                  crime.includes('lừa đảo') ||
                  crime.includes('trộm cắp');
          case 'cyber':
            return crime.includes('mạng') || 
                  crime.includes('công nghệ') ||
                  crime.includes('máy tính');
          case 'identity':
            return crime.includes('giả danh') || 
                  crime.includes('giả mạo');
          case 'violent':
            return crime.includes('giết người') || 
                  crime.includes('thương tích') ||
                  crime.includes('cố ý gây thương');
          default:
            return true;
        }
      });
    }
    
    setFilteredPersons(filtered);
  }, [wantedPersons, searchQuery, filterType]);
  
  useEffect(() => {
    // Apply filters when search query or filter type changes
    applyFilters();
  }, [applyFilters]);

  const loadWantedPersons = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const persons = await fetchWantedPersons();
      setWantedPersons(persons);
      setFilteredPersons(persons);
    } catch (err) {
      setError('Không thể tải danh sách đối tượng. Vui lòng thử lại sau.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };
  
  const handleFilterChange = (type: string) => {
    setFilterType(type);
  };

  return (
    <div className="wanted-page">
      <header className="wanted-header">
        <h1>Danh Sách Đối Tượng Truy Nã</h1>
        <p>Thông tin về các đối tượng đang bị truy nã</p>
      </header>
      
      <div className="wanted-filters">
        <div className="search-bar">
          <input
            type="text"
            placeholder="Tìm kiếm theo tên, địa chỉ hoặc tội danh..."
            value={searchQuery}
            onChange={handleSearchChange}
          />
          <button className="search-button">
            🔍
          </button>
        </div>
        
        <div className="category-filter">
          {categories.map((category) => (
            <button
              key={category}
              className={filterType === category ? 'active' : ''}
              onClick={() => handleFilterChange(category)}
            >
              {categoryNames[category]}
            </button>
          ))}
        </div>
      </div>
      
      <div className="refresh-bar">
        <button className="refresh-button" onClick={loadWantedPersons} disabled={isLoading}>
          {isLoading ? 'Đang tải...' : '↻ Làm mới'}
        </button>
        <span className="result-count">
          Hiển thị {filteredPersons.length} đối tượng
        </span>
      </div>
      
      {isLoading ? (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Đang tải danh sách...</p>
        </div>
      ) : error ? (
        <div className="error-container">
          <p className="error-message">{error}</p>
          <button onClick={loadWantedPersons}>Thử lại</button>
        </div>
      ) : filteredPersons.length === 0 ? (
        <div className="empty-container">
          <p>Không tìm thấy đối tượng phù hợp</p>
        </div>
      ) : (
        <div className="wanted-grid">
          {filteredPersons.map((person) => (
            <div key={person.id} className="wanted-person-container">
              <WantedPersonCard person={person} />
            </div>
          ))}
        </div>
      )}
      
      <footer className="wanted-footer">
        <p>
          Dữ liệu được cung cấp bởi{' '}
          <a 
            href="https://truyna.bocongan.gov.vn/"
            target="_blank"
            rel="noopener noreferrer"
          >
            Cổng thông tin điện tử Bộ Công an
          </a>
        </p>
      </footer>
    </div>
  );
} 