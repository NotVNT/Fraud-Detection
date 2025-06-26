import type { WantedPerson } from '../models/WantedPerson';
import './WantedPersonCard.css';

interface WantedPersonCardProps {
  person: WantedPerson;
}

export default function WantedPersonCard({ person }: WantedPersonCardProps) {
  const handleClick = () => {
    if (person.detailUrl) {
      window.open(person.detailUrl, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <div className="wanted-person-card" onClick={handleClick}>
      <div className="wanted-person-header">
        <div className="wanted-person-image-container">
          {person.imageUrl ? (
            <img 
              src={person.imageUrl} 
              alt={person.name} 
              className="wanted-person-image"
              onError={(e) => {
                (e.target as HTMLImageElement).src = 'https://via.placeholder.com/150?text=Không+có+hình';
              }}
            />
          ) : (
            <div className="wanted-person-no-image">
              <span className="wanted-person-initials">
                {person.name.split(' ').slice(-2).map(name => name[0]).join('')}
              </span>
            </div>
          )}
        </div>
        <div className="wanted-person-id">ID: {person.id}</div>
      </div>

      <div className="wanted-person-content">
        <h3 className="wanted-person-name">{person.name}</h3>
        
        <div className="wanted-person-details">
          <div className="wanted-person-detail">
            <span className="detail-label">Năm sinh:</span>
            <span className="detail-value">{person.birthYear || 'Không rõ'}</span>
          </div>
          
          <div className="wanted-person-detail">
            <span className="detail-label">Địa chỉ:</span>
            <span className="detail-value">{person.address || 'Không rõ'}</span>
          </div>
          
          <div className="wanted-person-detail wanted-crime">
            <span className="detail-label">Tội danh:</span>
            <span className="detail-value crime">{person.crime || 'Không rõ'}</span>
          </div>
          
          <div className="wanted-person-detail">
            <span className="detail-label">QĐ truy nã:</span>
            <span className="detail-value">{person.decisionNumber || 'Không rõ'}</span>
          </div>
          
          <div className="wanted-person-detail">
            <span className="detail-label">Đơn vị:</span>
            <span className="detail-value">{person.issuingUnit || 'Không rõ'}</span>
          </div>
        </div>
      </div>
      
      <div className="wanted-person-footer">
        <button className="wanted-person-more-btn">
          Xem chi tiết
        </button>
      </div>
    </div>
  );
} 