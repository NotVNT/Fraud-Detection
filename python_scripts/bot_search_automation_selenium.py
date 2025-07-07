from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, WebDriverException
from webdriver_manager.chrome import ChromeDriverManager
import time
import os
import argparse
from datetime import datetime
import sys

class SeleniumSearchBot:
    def __init__(self, platform="facebook", search_delay=2, screenshot_delay=3, headless=False, mobile_emulation=False):
        """
        Initialize the Selenium search bot
        
        Args:
            platform (str): The platform to search on ("facebook" or "youtube")
            search_delay (int): Delay in seconds after searching before taking screenshot
            screenshot_delay (int): Delay in seconds between searches
            headless (bool): Whether to run the browser in headless mode
            mobile_emulation (bool): Whether to emulate a mobile device
        """
        self.platform = platform.lower()
        self.search_delay = search_delay
        self.screenshot_delay = screenshot_delay
        self.screenshot_dir = "search_results"
        self.headless = headless
        self.mobile_emulation = mobile_emulation
        
        # Create directory for screenshots if it doesn't exist
        if not os.path.exists(self.screenshot_dir):
            os.makedirs(self.screenshot_dir)
            
        # Set platform-specific URLs
        self.urls = {
            "facebook": "https://www.facebook.com/",
            "youtube": "https://www.youtube.com/"
        }
        
        # Verify platform is supported
        if self.platform not in self.urls:
            raise ValueError(f"Unsupported platform: {platform}. Choose 'facebook' or 'youtube'")
            
        print(f"Bot initialized for {self.platform}")
        
        # Initialize the webdriver
        self._setup_driver()
    
    def _setup_driver(self):
        """Set up the Chrome webdriver"""
        chrome_options = Options()
        
        if self.headless:
            chrome_options.add_argument("--headless=new")
        
        # Add additional options for stability
        chrome_options.add_argument("--disable-notifications")
        chrome_options.add_argument("--disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        
        # Mobile emulation if requested
        if self.mobile_emulation:
            mobile_emulation = {
                "deviceName": "Pixel 5"
            }
            chrome_options.add_experimental_option("mobileEmulation", mobile_emulation)
        else:
            chrome_options.add_argument("--start-maximized")
        
        try:
            # Set up the driver
            self.driver = webdriver.Chrome(
                service=Service(ChromeDriverManager().install()),
                options=chrome_options
            )
            
            # Set an implicit wait
            self.driver.implicitly_wait(10)
        except WebDriverException as e:
            print(f"Error setting up Chrome driver: {e}")
            print("Make sure Chrome is installed and updated.")
            sys.exit(1)
        
    def open_platform(self):
        """Open the browser and navigate to the platform"""
        try:
            self.driver.get(self.urls[self.platform])
            print(f"Opened {self.platform}")
            
            # Wait for the page to load
            time.sleep(3)
            
            # Handle cookies consent if it appears
            self._handle_cookies_consent()
            
        except Exception as e:
            print(f"Error opening {self.platform}: {e}")
    
    def _handle_cookies_consent(self):
        """Handle cookies consent dialog if it appears"""
        try:
            # Different platforms have different cookie consent buttons
            if self.platform == "facebook":
                # Try various selectors for Facebook consent buttons
                selectors = [
                    "//button[contains(text(), 'Accept')]",
                    "//button[contains(text(), 'Allow')]",
                    "//button[contains(text(), 'OK')]",
                    "//button[contains(@aria-label, 'Accept')]",
                    "//button[contains(@data-testid, 'cookie-policy')]"
                ]
                
                for selector in selectors:
                    try:
                        consent_buttons = self.driver.find_elements(By.XPATH, selector)
                        if consent_buttons:
                            consent_buttons[0].click()
                            print("Clicked Facebook consent button")
                            time.sleep(1)
                            return
                    except Exception:
                        continue
            
            elif self.platform == "youtube":
                # YouTube cookie consent - various selectors
                selectors = [
                    "//button[contains(@aria-label, 'Accept')]",
                    "//button[contains(text(), 'Accept all')]",
                    "//button[contains(text(), 'I agree')]",
                    "//button[contains(@aria-label, 'Agree')]"
                ]
                
                for selector in selectors:
                    try:
                        consent_buttons = self.driver.find_elements(By.XPATH, selector)
                        if consent_buttons:
                            consent_buttons[0].click()
                            print("Clicked YouTube consent button")
                            time.sleep(1)
                            return
                    except Exception:
                        continue
                    
        except Exception as e:
            print(f"Could not handle cookie consent: {e}")
            # Continue anyway
    
    def search_keyword(self, keyword):
        """
        Search for a keyword on the platform
        
        Args:
            keyword (str): The keyword to search for
        """
        print(f"Searching for: {keyword}")
        
        try:
            if self.platform == "facebook":
                self._search_facebook(keyword)
            elif self.platform == "youtube":
                self._search_youtube(keyword)
            
            # Wait for search results to load
            time.sleep(self.search_delay)
            
            # Take screenshot of search results
            self.capture_screenshot(keyword)
            
            # Wait before next search
            time.sleep(self.screenshot_delay)
            
        except Exception as e:
            print(f"Error searching for {keyword}: {e}")
            # Try to capture screenshot even if search failed
            try:
                self.capture_screenshot(f"error_{keyword}")
            except Exception:
                pass
    
    def _search_facebook(self, keyword):
        """Facebook-specific search implementation"""
        try:
            # Try to find the search box using various selectors
            search_selectors = [
                "//input[@placeholder='Search Facebook']",
                "//input[@aria-label='Search Facebook']",
                "//input[@type='search']",
                "//input[contains(@aria-label, 'Search')]"
            ]
            
            search_box = None
            for selector in search_selectors:
                try:
                    elements = self.driver.find_elements(By.XPATH, selector)
                    if elements:
                        search_box = elements[0]
                        break
                except Exception:
                    continue
            
            if search_box:
                search_box.clear()
                search_box.send_keys(keyword)
                time.sleep(0.5)
                search_box.send_keys(Keys.RETURN)
                print("Found and used Facebook search box")
                return
            
            # If can't find the search box, try using the shortcut
            print("Using Facebook search shortcut")
            self.driver.find_element(By.TAG_NAME, "body").send_keys("/")
            time.sleep(1)
            search_box = self.driver.switch_to.active_element
            search_box.send_keys(keyword)
            time.sleep(0.5)
            search_box.send_keys(Keys.RETURN)
            
        except Exception as e:
            print(f"Facebook search failed: {e}")
            raise
    
    def _search_youtube(self, keyword):
        """YouTube-specific search implementation"""
        try:
            # Try different selectors for YouTube search
            search_selectors = [
                (By.NAME, "search_query"),
                (By.XPATH, "//input[@id='search']"),
                (By.XPATH, "//input[@aria-label='Search']"),
                (By.XPATH, "//input[@type='search']")
            ]
            
            search_box = None
            for by_method, selector in search_selectors:
                try:
                    elements = self.driver.find_elements(by_method, selector)
                    if elements:
                        search_box = elements[0]
                        break
                except Exception:
                    continue
            
            if search_box:
                search_box.clear()
                search_box.send_keys(keyword)
                time.sleep(0.5)
                search_box.send_keys(Keys.RETURN)
                print("Found and used YouTube search box")
                return
                
            # For mobile YouTube, might need to click search icon first
            search_icons = self.driver.find_elements(By.XPATH, 
                "//button[contains(@aria-label, 'Search')]")
            if search_icons:
                search_icons[0].click()
                time.sleep(1)
                
                # Now try to find the search input again
                for by_method, selector in search_selectors:
                    try:
                        elements = self.driver.find_elements(by_method, selector)
                        if elements:
                            search_box = elements[0]
                            break
                    except Exception:
                        continue
                
                if search_box:
                    search_box.clear()
                    search_box.send_keys(keyword)
                    time.sleep(0.5)
                    search_box.send_keys(Keys.RETURN)
                    print("Found and used YouTube search box after clicking search icon")
                    return
            
            raise Exception("Could not find YouTube search box")
            
        except Exception as e:
            print(f"YouTube search failed: {e}")
            raise
    
    def capture_screenshot(self, keyword):
        """
        Capture a screenshot of the search results
        
        Args:
            keyword (str): The keyword that was searched for (used in filename)
        """
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.screenshot_dir}/{self.platform}_{keyword.replace(' ', '_')}_{timestamp}.png"
        
        try:
            # Take screenshot
            self.driver.save_screenshot(filename)
            print(f"Screenshot saved: {filename}")
            return filename
        except Exception as e:
            print(f"Error taking screenshot: {e}")
            return None
    
    def batch_search(self, keywords):
        """
        Search for multiple keywords in sequence
        
        Args:
            keywords (list): List of keywords to search for
        Returns:
            list: Paths to screenshot files
        """
        screenshot_paths = []
        for keyword in keywords:
            try:
                self.search_keyword(keyword)
                # Add the latest screenshot path to the list
                latest_file = self._get_latest_screenshot()
                if latest_file:
                    screenshot_paths.append(latest_file)
            except Exception as e:
                print(f"Error during batch search for '{keyword}': {e}")
        
        return screenshot_paths
    
    def _get_latest_screenshot(self):
        """Get the path to the most recently created screenshot"""
        if not os.path.exists(self.screenshot_dir):
            return None
            
        files = [os.path.join(self.screenshot_dir, f) for f in os.listdir(self.screenshot_dir) 
                if f.endswith('.png')]
        if not files:
            return None
            
        return max(files, key=os.path.getctime)
            
    def scroll_results(self, num_scrolls=3, scroll_delay=2):
        """
        Scroll down to see more results
        
        Args:
            num_scrolls (int): Number of times to scroll down
            scroll_delay (int): Delay in seconds between scrolls
        Returns:
            list: Paths to screenshot files taken after scrolling
        """
        screenshot_paths = []
        for i in range(num_scrolls):
            # Scroll down
            self.driver.execute_script("window.scrollBy(0, 800)")
            time.sleep(scroll_delay)
            
            # Take screenshot after each scroll
            screenshot_file = self.capture_screenshot(f"scroll_{i+1}")
            if screenshot_file:
                screenshot_paths.append(screenshot_file)
        
        return screenshot_paths
    
    def close(self):
        """Close the browser and clean up"""
        if hasattr(self, 'driver'):
            self.driver.quit()
            print("Browser closed")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Automated search bot for Facebook and YouTube using Selenium')
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
    parser.add_argument('--headless', action='store_true',
                        help='Run in headless mode (no browser UI)')
    parser.add_argument('--mobile', action='store_true',
                        help='Emulate a mobile device')
    parser.add_argument('--wait-login', type=int, default=15,
                        help='Time in seconds to wait for manual login')
    
    args = parser.parse_args()
    
    bot = None
    try:
        # Initialize and run the bot
        bot = SeleniumSearchBot(
            platform=args.platform,
            search_delay=args.search_delay,
            screenshot_delay=args.screenshot_delay,
            headless=args.headless,
            mobile_emulation=args.mobile
        )
        
        # Open browser and navigate to platform
        bot.open_platform()
        
        # Wait for login if needed
        if not args.headless:
            print(f"If you need to log in, do so now.")
            print(f"The script will continue in {args.wait_login} seconds...")
            time.sleep(args.wait_login)
        
        # Perform searches
        screenshot_paths = bot.batch_search(args.keywords)
        
        # Scroll results if specified
        if args.scroll > 0:
            scroll_screenshots = bot.scroll_results(num_scrolls=args.scroll)
            screenshot_paths.extend(scroll_screenshots)
            
        print(f"Search automation completed successfully! Took {len(screenshot_paths)} screenshots.")
        
        # Return the list of screenshot paths (useful for programmatic use)
        return screenshot_paths
        
    except Exception as e:
        print(f"Error: {e}")
        return []
    finally:
        # Clean up
        if bot:
            bot.close()

if __name__ == "__main__":
    print("=" * 60)
    print("Selenium Search Bot")
    print("This script will automate searches on Facebook or YouTube.")
    print("=" * 60)
    
    main() 