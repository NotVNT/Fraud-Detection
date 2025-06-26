import { useState } from 'react'
import NavBar from './components/NavBar'
import NewsPage from './pages/NewsPage'
import WantedListPage from './pages/WantedListPage'
import './App.css'

function App() {
  const [activeScreen, setActiveScreen] = useState('news')

  const handleNavigate = (screen: string) => {
    setActiveScreen(screen)
  }

  return (
    <div className="app">
      <NavBar 
        onNavigate={handleNavigate} 
        activeScreen={activeScreen} 
      />
      
      <main className="content">
        {activeScreen === 'news' && <NewsPage />}
        {activeScreen === 'wanted' && <WantedListPage />}
      </main>
      
      <footer className="app-footer">
        <p>&copy; {new Date().getFullYear()} Phòng Chống Lừa Đảo</p>
      </footer>
    </div>
  )
}

export default App
