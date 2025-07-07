import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class BotScriptsManager {
  static const String _seleniumScriptName = 'bot_search_automation_selenium.py';
  static const String _pyautoguiScriptName = 'bot_search_automation.py';
  
  /// Ensures that the Python scripts are available in the app's documents directory
  static Future<bool> ensureScriptsAvailable() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final scriptsDir = Directory(path.join(directory.path, 'python_scripts'));
      
      if (!await scriptsDir.exists()) {
        await scriptsDir.create(recursive: true);
      }
      
      final seleniumScriptPath = path.join(scriptsDir.path, _seleniumScriptName);
      final pyautoguiScriptPath = path.join(scriptsDir.path, _pyautoguiScriptName);
      
      // Check if scripts already exist
      bool seleniumExists = await File(seleniumScriptPath).exists();
      bool pyautoguiExists = await File(pyautoguiScriptPath).exists();
      
      if (!seleniumExists) {
        await _copyScriptFromAssets(_seleniumScriptName, seleniumScriptPath);
      }
      
      if (!pyautoguiExists) {
        await _copyScriptFromAssets(_pyautoguiScriptName, pyautoguiScriptPath);
      }
      
      // Verify scripts are now available
      seleniumExists = await File(seleniumScriptPath).exists();
      pyautoguiExists = await File(pyautoguiScriptPath).exists();
      
      return seleniumExists && pyautoguiExists;
    } catch (e) {
      debugPrint('Error ensuring scripts are available: $e');
      return false;
    }
  }
  
  /// Copy a script from the assets folder to the local filesystem
  static Future<void> _copyScriptFromAssets(String assetName, String targetPath) async {
    try {
      // Try to load the script from assets
      final byteData = await rootBundle.load('python_scripts/$assetName');
      
      // Write to the file system
      final file = File(targetPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      debugPrint('Successfully copied $assetName to $targetPath');
    } catch (e) {
      debugPrint('Error copying script $assetName: $e');
      // If the asset doesn't exist, create the file with the hardcoded content
      await _createScriptWithHardcodedContent(assetName, targetPath);
    }
  }
  
  /// Create a script file with hardcoded content as fallback
  static Future<void> _createScriptWithHardcodedContent(String scriptName, String targetPath) async {
    final file = File(targetPath);
    
    if (scriptName == _seleniumScriptName) {
      await file.writeAsString(_getSeleniumScriptContent());
    } else if (scriptName == _pyautoguiScriptName) {
      await file.writeAsString(_getPyAutoGUIScriptContent());
    }
    
    debugPrint('Created $scriptName with hardcoded content');
  }
  
  /// Get the content of the Selenium script
  static String _getSeleniumScriptContent() {
    return '''
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from webdriver_manager.chrome import ChromeDriverManager
import time
import os
import argparse
from datetime import datetime

class SeleniumSearchBot:
    def __init__(self, platform="facebook", search_delay=2, screenshot_delay=3, headless=False):
        """
        Initialize the Selenium search bot
        
        Args:
            platform (str): The platform to search on ("facebook" or "youtube")
            search_delay (int): Delay in seconds after searching before taking screenshot
            screenshot_delay (int): Delay in seconds between searches
            headless (bool): Whether to run the browser in headless mode
        """
        self.platform = platform.lower()
        self.search_delay = search_delay
        self.screenshot_delay = screenshot_delay
        self.screenshot_dir = "search_results"
        self.headless = headless
        
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
            chrome_options.add_argument("--headless")
        
        # Add additional options for stability
        chrome_options.add_argument("--disable-notifications")
        chrome_options.add_argument("--disable-infobars")
        chrome_options.add_argument("--start-maximized")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        
        # Set up the driver
        self.driver = webdriver.Chrome(
            service=Service(ChromeDriverManager().install()),
            options=chrome_options
        )
        
        # Set an implicit wait
        self.driver.implicitly_wait(10)
        
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
                # Try to find and click the "Accept All" button for cookies
                consent_buttons = self.driver.find_elements(By.XPATH, 
                    "//button[contains(text(), 'Accept') or contains(text(), 'Allow') or contains(text(), 'OK')]")
                if consent_buttons:
                    consent_buttons[0].click()
                    time.sleep(1)
            
            elif self.platform == "youtube":
                # YouTube cookie consent
                consent_buttons = self.driver.find_elements(By.XPATH, 
                    "//button[contains(@aria-label, 'Accept') or contains(text(), 'Accept all')]")
                if consent_buttons:
                    consent_buttons[0].click()
                    time.sleep(1)
                    
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
                # Facebook search
                try:
                    # Try to find the search box
                    search_box = WebDriverWait(self.driver, 10).until(
                        EC.presence_of_element_located((By.XPATH, "//input[@placeholder='Search Facebook' or @aria-label='Search Facebook']"))
                    )
                    search_box.clear()
                    search_box.send_keys(keyword)
                    search_box.send_keys(Keys.RETURN)
                except TimeoutException:
                    # If can't find the search box, try using the shortcut
                    self.driver.find_element(By.TAG_NAME, "body").send_keys("/")
                    time.sleep(1)
                    search_box = self.driver.switch_to.active_element
                    search_box.send_keys(keyword)
                    search_box.send_keys(Keys.RETURN)
            
            elif self.platform == "youtube":
                # YouTube search
                search_box = WebDriverWait(self.driver, 10).until(
                    EC.presence_of_element_located((By.NAME, "search_query"))
                )
                search_box.clear()
                search_box.send_keys(keyword)
                search_box.send_keys(Keys.RETURN)
            
            # Wait for search results to load
            time.sleep(self.search_delay)
            
            # Take screenshot of search results
            self.capture_screenshot(keyword)
            
            # Wait before next search
            time.sleep(self.screenshot_delay)
            
        except Exception as e:
            print(f"Error searching for {keyword}: {e}")
    
    def capture_screenshot(self, keyword):
        """
        Capture a screenshot of the search results
        
        Args:
            keyword (str): The keyword that was searched for (used in filename)
        """
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.screenshot_dir}/{self.platform}_{keyword.replace(' ', '_')}_{timestamp}.png"
        
        # Take screenshot
        self.driver.save_screenshot(filename)
        print(f"Screenshot saved: {filename}")
    
    def batch_search(self, keywords):
        """
        Search for multiple keywords in sequence
        
        Args:
            keywords (list): List of keywords to search for
        """
        for keyword in keywords:
            self.search_keyword(keyword)
            
    def scroll_results(self, num_scrolls=3, scroll_delay=2):
        """
        Scroll down to see more results
        
        Args:
            num_scrolls (int): Number of times to scroll down
            scroll_delay (int): Delay in seconds between scrolls
        """
        for i in range(num_scrolls):
            # Scroll down
            self.driver.execute_script("window.scrollBy(0, 800)")
            time.sleep(scroll_delay)
            
            # Take screenshot after each scroll
            self.capture_screenshot(f"scroll_{i+1}")
    
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
            headless=args.headless
        )
        
        # Open browser and navigate to platform
        bot.open_platform()
        
        # Wait for login if needed
        if not args.headless:
            print(f"If you need to log in, do so now.")
            print(f"The script will continue in {args.wait_login} seconds...")
            time.sleep(args.wait_login)
        
        # Perform searches
        bot.batch_search(args.keywords)
        
        # Scroll results if specified
        if args.scroll > 0:
            bot.scroll_results(num_scrolls=args.scroll)
            
        print("Search automation completed successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Clean up
        if bot:
            bot.close()

if __name__ == "__main__":
    main()
''';
  }
  
  /// Get the content of the PyAutoGUI script
  static String _getPyAutoGUIScriptContent() {
    return '''
import pyautogui
import time
import os
from datetime import datetime
import argparse

class SearchBot:
    def __init__(self, platform="facebook", search_delay=2, screenshot_delay=3):
        """
        Initialize the search bot
        
        Args:
            platform (str): The platform to search on ("facebook" or "youtube")
            search_delay (int): Delay in seconds after searching before taking screenshot
            screenshot_delay (int): Delay in seconds between searches
        """
        self.platform = platform.lower()
        self.search_delay = search_delay
        self.screenshot_delay = screenshot_delay
        self.screenshot_dir = "search_results"
        
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
    
    def open_browser(self, browser="chrome"):
        """Open the browser and navigate to the platform"""
        if browser.lower() == "chrome":
            # Open Chrome
            pyautogui.hotkey('win', 'r')
            pyautogui.write('chrome')
            pyautogui.press('enter')
            time.sleep(2)  # Wait for Chrome to open
            
            # Navigate to the platform
            pyautogui.write(self.urls[self.platform])
            pyautogui.press('enter')
            time.sleep(5)  # Wait for the page to load
            
            print(f"Opened {self.platform} in Chrome")
        else:
            raise ValueError(f"Unsupported browser: {browser}. Currently only Chrome is supported.")
    
    def search_keyword(self, keyword):
        """
        Search for a keyword on the platform
        
        Args:
            keyword (str): The keyword to search for
        """
        print(f"Searching for: {keyword}")
        
        # Press Escape to close any popups
        pyautogui.press('escape')
        
        # Different search approaches based on platform
        if self.platform == "facebook":
            # Facebook search
            search_shortcut = '/'  # Facebook search shortcut
            pyautogui.press(search_shortcut)
            time.sleep(1)
            pyautogui.write(keyword)
            time.sleep(0.5)
            pyautogui.press('enter')
        
        elif self.platform == "youtube":
            # YouTube search
            pyautogui.press('/')  # YouTube search shortcut
            time.sleep(1)
            pyautogui.write(keyword)
            time.sleep(0.5)
            pyautogui.press('enter')
        
        # Wait for search results to load
        time.sleep(self.search_delay)
        
        # Take screenshot of search results
        self.capture_screenshot(keyword)
        
        # Wait before next search
        time.sleep(self.screenshot_delay)
    
    def capture_screenshot(self, keyword):
        """
        Capture a screenshot of the search results
        
        Args:
            keyword (str): The keyword that was searched for (used in filename)
        """
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.screenshot_dir}/{self.platform}_{keyword.replace(' ', '_')}_{timestamp}.png"
        
        # Take screenshot
        screenshot = pyautogui.screenshot()
        screenshot.save(filename)
        print(f"Screenshot saved: {filename}")
    
    def batch_search(self, keywords):
        """
        Search for multiple keywords in sequence
        
        Args:
            keywords (list): List of keywords to search for
        """
        for keyword in keywords:
            self.search_keyword(keyword)
            
    def scroll_results(self, num_scrolls=3, scroll_delay=2):
        """
        Scroll down to see more results
        
        Args:
            num_scrolls (int): Number of times to scroll down
            scroll_delay (int): Delay in seconds between scrolls
        """
        for i in range(num_scrolls):
            pyautogui.scroll(-1000)  # Scroll down
            time.sleep(scroll_delay)
            
            # Take screenshot after each scroll
            self.capture_screenshot(f"scroll_{i+1}")

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
    
    args = parser.parse_args()
    
    try:
        # Initialize and run the bot
        bot = SearchBot(
            platform=args.platform,
            search_delay=args.search_delay,
            screenshot_delay=args.screenshot_delay
        )
        
        # Open browser and navigate to platform
        bot.open_browser()
        
        # Wait for login if needed
        print("If you need to log in, do so now.")
        print("The script will continue in 15 seconds...")
        time.sleep(15)
        
        # Perform searches
        bot.batch_search(args.keywords)
        
        # Scroll results if specified
        if args.scroll > 0:
            bot.scroll_results(num_scrolls=args.scroll)
            
        print("Search automation completed successfully!")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
''';
  }
} 