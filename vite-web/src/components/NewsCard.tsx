import type { NewsItem } from '../models/NewsItem';
import './NewsCard.css';

interface NewsCardProps {
  news: NewsItem;
}

export default function NewsCard({ news }: NewsCardProps) {
  const handleClick = () => {
    window.open(news.articleUrl, '_blank', 'noopener,noreferrer');
  };

  return (
    <div className="news-card" onClick={handleClick}>
      <div className="news-image-container">
        {news.imageUrl && news.imageUrl !== 'no_image' ? (
          <img 
            src={news.imageUrl} 
            alt={news.title} 
            className="news-image"
            onError={(e) => {
              (e.target as HTMLImageElement).src = 'https://via.placeholder.com/300x200?text=Không+có+hình';
            }}
          />
        ) : (
          <div className="news-no-image">
            <span>Không có hình</span>
          </div>
        )}
        <div className="news-category">{news.category}</div>
      </div>
      
      <div className="news-content">
        <h3 className="news-title">{news.title}</h3>
        
        <div className="news-meta">
          <span className="news-source">{news.source}</span>
          <span className="news-time">{news.timeAgo}</span>
        </div>
        
        <div className="news-tags">
          {news.tags.map((tag, index) => (
            <span key={index} className="news-tag">#{tag}</span>
          ))}
        </div>
        
        <div className="news-stats">
          <span className="news-likes">
            <i className="icon-heart">❤️</i> {news.likes}
          </span>
          <span className="news-comments">
            <i className="icon-comment">💬</i> {news.comments}
          </span>
        </div>
      </div>
    </div>
  );
} 