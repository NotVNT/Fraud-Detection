import pyautogui
import time
import os
import sys
from datetime import datetime
import argparse
import logging

class SearchBot:
    def __init__(self, platform="facebook", search_delay=2, screenshot_delay=3, debug_mode=False):
        """
        Initialize the search bot
        
        Args:
            platform (str): The platform to search on ("facebook" or "youtube")
            search_delay (int): Delay in seconds after searching before taking screenshot
            screenshot_delay (int): Delay in seconds between searches
            debug_mode (bool): Whether to enable debug mode with more detailed logging
        """
        self.platform = platform.lower()
        self.search_delay = search_delay
        self.screenshot_delay = screenshot_delay
        self.screenshot_dir = "search_results"
        self.debug_mode = debug_mode
        self.screenshot_paths = []
        
        # Set up logging
        logging_level = logging.DEBUG if debug_mode else logging.INFO
        logging.basicConfig(
            level=logging_level,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger('SearchBot')
        
        # Create directory for screenshots if it doesn't exist
        if not os.path.exists(self.screenshot_dir):
            os.makedirs(self.screenshot_dir)
            self.logger.info(f"Created screenshots directory: {self.screenshot_dir}")
            
        # Set platform-specific URLs
        self.urls = {
            "facebook": "https://www.facebook.com/",
            "youtube": "https://www.youtube.com/"
        }
        
        # Verify platform is supported
        if self.platform not in self.urls:
            raise ValueError(f"Unsupported platform: {platform}. Choose 'facebook' or 'youtube'")
            
        self.logger.info(f"Bot initialized for {self.platform}")
    
    def open_browser(self, browser="chrome"):
        """Open the browser and navigate to the platform"""
        try:
            if browser.lower() == "chrome":
                # Open Chrome
                self.logger.info("Opening Chrome browser")
                pyautogui.hotkey('win', 'r')
                time.sleep(0.5)
                pyautogui.write('chrome')
                pyautogui.press('enter')
                time.sleep(2)  # Wait for Chrome to open
                
                # Navigate to the platform
                self.logger.info(f"Navigating to {self.urls[self.platform]}")
                pyautogui.write(self.urls[self.platform])
                pyautogui.press('enter')
                time.sleep(5)  # Wait for the page to load
                
                self.logger.info(f"Opened {self.platform} in Chrome")
                
                # Try to handle cookie consent if it appears
                self._handle_cookie_consent()
                
                return True
            else:
                raise ValueError(f"Unsupported browser: {browser}. Currently only Chrome is supported.")
        except Exception as e:
            self.logger.error(f"Error opening browser: {e}")
            return False
    
    def _handle_cookie_consent(self):
        """Try to handle cookie consent dialogs by looking for and clicking buttons"""
        self.logger.info("Looking for cookie consent dialogs")
        
        # Wait a moment for any dialogs to appear
        time.sleep(2)
        
        # For Facebook or YouTube, common accept buttons have "Accept", "OK", "I agree" etc.
        # Try to find them by searching for buttons at common positions
        
        # Try pressing Tab a few times and then Enter to navigate to accept button
        self.logger.info("Trying to navigate to accept button using keyboard")
        for _ in range(3):
            pyautogui.press('tab')
            time.sleep(0.2)
        
        # Try pressing Enter to click the focused button
        pyautogui.press('enter')
        time.sleep(1)
        
        # If that didn't work, try looking for buttons at common screen locations
        # This is platform-specific and may need to be adjusted based on screen resolution
        self.logger.info("Trying to click accept button at common positions")
        
        # Try pressing Escape to close any dialogs that don't need explicit acceptance
        pyautogui.press('escape')
        
        # Wait a moment to allow any animations to complete
        time.sleep(1)
    
    def search_keyword(self, keyword):
        """
        Search for a keyword on the platform
        
        Args:
            keyword (str): The keyword to search for
        
        Returns:
            str: Path to screenshot file or None if failed
        """
        self.logger.info(f"Searching for: {keyword}")
        
        # Press Escape to close any popups
        pyautogui.press('escape')
        
        try:
            # Different search approaches based on platform
            if self.platform == "facebook":
                self._search_facebook(keyword)
            elif self.platform == "youtube":
                self._search_youtube(keyword)
            
            # Wait for search results to load
            self.logger.info(f"Waiting {self.search_delay} seconds for results to load")
            time.sleep(self.search_delay)
            
            # Take screenshot of search results
            screenshot_path = self.capture_screenshot(keyword)
            
            # Wait before next search
            time.sleep(self.screenshot_delay)
            
            return screenshot_path
            
        except Exception as e:
            self.logger.error(f"Error during search for '{keyword}': {e}")
            # Try to take a screenshot of the error state
            try:
                return self.capture_screenshot(f"error_{keyword}")
            except Exception:
                return None
    
    def _search_facebook(self, keyword):
        """Facebook-specific search implementation"""
        self.logger.info("Using Facebook search")
        
        # Try the search shortcut first
        search_shortcut = '/'  # Facebook search shortcut
        self.logger.debug(f"Pressing search shortcut: {search_shortcut}")
        pyautogui.press(search_shortcut)
        time.sleep(1)
        
        # Clear any existing text (select all and delete)
        pyautogui.hotkey('ctrl', 'a')
        pyautogui.press('delete')
        time.sleep(0.5)
        
        # Type the keyword
        self.logger.debug(f"Typing search keyword: {keyword}")
        pyautogui.write(keyword)
        time.sleep(0.5)
        
        # Press Enter to search
        self.logger.debug("Pressing Enter to search")
        pyautogui.press('enter')
    
    def _search_youtube(self, keyword):
        """YouTube-specific search implementation"""
        self.logger.info("Using YouTube search")
        
        # Try the search shortcut first
        search_shortcut = '/'  # YouTube search shortcut
        self.logger.debug(f"Pressing search shortcut: {search_shortcut}")
        pyautogui.press(search_shortcut)
        time.sleep(1)
        
        # If that doesn't work, try clicking on the search box
        # This is a fallback and may need to be adjusted based on screen resolution
        if self.debug_mode:
            self.logger.debug("Attempting to click on search box")
            # These coordinates are approximate and may need adjustment
            pyautogui.click(x=500, y=40)  # Approximate position of search box
            time.sleep(0.5)
        
        # Clear any existing text (select all and delete)
        pyautogui.hotkey('ctrl', 'a')
        pyautogui.press('delete')
        time.sleep(0.5)
        
        # Type the keyword
        self.logger.debug(f"Typing search keyword: {keyword}")
        pyautogui.write(keyword)
        time.sleep(0.5)
        
        # Press Enter to search
        self.logger.debug("Pressing Enter to search")
        pyautogui.press('enter')
    
    def capture_screenshot(self, keyword):
        """
        Capture a screenshot of the search results
        
        Args:
            keyword (str): The keyword that was searched for (used in filename)
        
        Returns:
            str: Path to the saved screenshot
        """
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.screenshot_dir}/{self.platform}_{keyword.replace(' ', '_')}_{timestamp}.png"
        
        try:
            # Take screenshot
            self.logger.info(f"Taking screenshot for keyword: {keyword}")
            screenshot = pyautogui.screenshot()
            screenshot.save(filename)
            self.logger.info(f"Screenshot saved: {filename}")
            
            # Add to the list of screenshots
            self.screenshot_paths.append(filename)
            
            return filename
        except Exception as e:
            self.logger.error(f"Error taking screenshot: {e}")
            return None
    
    def batch_search(self, keywords):
        """
        Search for multiple keywords in sequence
        
        Args:
            keywords (list): List of keywords to search for
        
        Returns:
            list: Paths to screenshot files
        """
        self.logger.info(f"Starting batch search for {len(keywords)} keywords")
        screenshot_paths = []
        
        for keyword in keywords:
            try:
                screenshot_path = self.search_keyword(keyword)
                if screenshot_path:
                    screenshot_paths.append(screenshot_path)
            except Exception as e:
                self.logger.error(f"Error during batch search for '{keyword}': {e}")
        
        self.logger.info(f"Batch search completed. Captured {len(screenshot_paths)} screenshots")
        return screenshot_paths
            
    def scroll_results(self, num_scrolls=3, scroll_delay=2):
        """
        Scroll down to see more results
        
        Args:
            num_scrolls (int): Number of times to scroll down
            scroll_delay (int): Delay in seconds between scrolls
        
        Returns:
            list: Paths to screenshots taken after scrolling
        """
        self.logger.info(f"Scrolling results {num_scrolls} times")
        screenshot_paths = []
        
        for i in range(num_scrolls):
            self.logger.debug(f"Scroll {i+1}/{num_scrolls}")
            pyautogui.scroll(-1000)  # Scroll down
            time.sleep(scroll_delay)
            
            # Take screenshot after each scroll
            screenshot_path = self.capture_screenshot(f"scroll_{i+1}")
            if screenshot_path:
                screenshot_paths.append(screenshot_path)
        
        return screenshot_paths
    
    def get_screenshots(self):
        """
        Get the list of screenshot paths
        
        Returns:
            list: Paths to all screenshots taken
        """
        return self.screenshot_paths

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Automated search bot for Facebook and YouTube')
    parser.add_argument('--platform', default='facebook', choices=['facebook', 'youtube'], 
                        help='Platform to search on (facebook or youtube)')
    parser.add_argument('--keywords', nargs='+', required=True, 
                        help='Keywords to search for (space-separated)')
    parser.add_argument('--search-delay', type=int, default=3, 
                        help='Delay in seconds after searching before taking screenshot')
    parser.add_argument('--screenshot-delay', type=int, default=2, 
                        help='Delay in seconds between searches')
    parser.add_argument('--scroll', type=int, default=0, 
                        help='Number of times to scroll down for each search')
    parser.add_argument('--debug', action='store_true',
                        help='Enable debug logging')
    
    args = parser.parse_args()
    
    try:
        # Initialize and run the bot
        bot = SearchBot(
            platform=args.platform,
            search_delay=args.search_delay,
            screenshot_delay=args.screenshot_delay,
            debug_mode=args.debug
        )
        
        # Open browser and navigate to platform
        if not bot.open_browser():
            print("Failed to open browser. Exiting.")
            sys.exit(1)
        
        # Wait for login if needed
        print("If you need to log in, do so now.")
        print("The script will continue in 15 seconds...")
        time.sleep(15)
        
        # Perform searches
        screenshot_paths = bot.batch_search(args.keywords)
        
        # Scroll results if specified
        if args.scroll > 0:
            scroll_screenshots = bot.scroll_results(num_scrolls=args.scroll)
            screenshot_paths.extend(scroll_screenshots)
            
        print(f"Search automation completed successfully!")
        print(f"Took {len(screenshot_paths)} screenshots. Files saved in {os.path.abspath(bot.screenshot_dir)}")
        
        # Return the paths (useful for programmatic use)
        return screenshot_paths
        
    except Exception as e:
        print(f"Error: {e}")
        return []

if __name__ == "__main__":
    # Display warning and confirmation
    print("=" * 60)
    print("WARNING: This script will take control of your mouse and keyboard.")
    print("Make sure you don't interact with your computer while it's running.")
    print("=" * 60)
    
    # Ask for confirmation
    confirm = input("Do you want to continue? (y/n): ")
    if confirm.lower() == 'y':
        main()
    else:
        print("Script execution cancelled.") 