import { useState } from 'react';
import './NavBar.css';

interface NavBarProps {
  onNavigate: (screen: string) => void;
  activeScreen: string;
}

export default function NavBar({ onNavigate, activeScreen }: NavBarProps) {
  const [menuOpen, setMenuOpen] = useState(false);

  const toggleMenu = () => {
    setMenuOpen(!menuOpen);
  };

  const navigate = (screen: string) => {
    onNavigate(screen);
    setMenuOpen(false);
  };

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <div className="navbar-logo" onClick={() => navigate('home')}>
          <span className="logo-icon">🛡️</span>
          <span className="logo-text">Phòng Chống Lừa Đảo</span>
        </div>
        
        <div className={`navbar-menu ${menuOpen ? 'open' : ''}`}>
          <button 
            className={`nav-item ${activeScreen === 'news' ? 'active' : ''}`}
            onClick={() => navigate('news')}
          >
            <span className="nav-icon">📰</span>
            <span className="nav-text">Tin Tức</span>
          </button>
          
          <button 
            className={`nav-item ${activeScreen === 'wanted' ? 'active' : ''}`}
            onClick={() => navigate('wanted')}
          >
            <span className="nav-icon">🔍</span>
            <span className="nav-text">Truy Nã</span>
          </button>
        </div>
        
        <button className="menu-toggle" onClick={toggleMenu}>
          {menuOpen ? '✕' : '☰'}
        </button>
      </div>
    </nav>
  );
} 