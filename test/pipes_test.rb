require 'test/unit'
require 'yaml'
require 'selenium-webdriver'
class PipesTest < Test::Unit::TestCase
  @@config_path = File.expand_path("#{File.dirname(__FILE__)}/../config")
  @@config = {}
  @@config = YAML.load_file("#{@@config_path}/config.yml") if(File.exists?("#{@@config_path}/config.yml"))

  def setup
    @driver = Selenium::WebDriver.for :firefox
  end
  
  def teardown
    @driver.quit unless @driver.nil?
  end
  
  def test_nyu01_subset
    run_pipe '/html/body/form/div[1]/div/div/div/div[1]/table/tbody/tr[21]'
  end
  
  def run_pipe(pipe_locator)
    # Go to back office
    @driver.navigate.to "#{@@config["bo_url"]}/primo_publishing/admin/acegilogin.jsp"
    # Enter credentials
    @driver.find_element(:name, "j_username").send_keys @@config["username"]
    @driver.find_element(:name, "j_password").send_keys @@config["password"]
    # Login
    @driver.find_element(:id, "loginForm").submit
    # Click "Monitor Primo Status"
    locator = ".topTable .LeftCul a"
    wait_for_css(locator)
    @driver.find_elements(:css, locator).first.click
    # Click "Pipe Monitoring"
    locator = "a.broad_link"
    wait_for_css(locator)
    @driver.find_elements(:css, locator).first.click
    # Leave if terminating
    locator = pipe_locator + "/td[5]/a"
    wait_for_xpath(locator)
    return if @driver.find_elements(:xpath, locator).first.text.eql?("pending termination")
    # Terminate if necessary
    locator = pipe_locator + "/td[7]/a"
    wait_for_xpath(locator)
    if @driver.find_elements(:xpath, locator).first.attribute('href').nil?
      # Click status
      locator = pipe_locator + "/td[5]/a"
      wait_for_xpath(locator)
      @driver.find_elements(:xpath, locator).first.click
      # Click Terminate
      locator = '//*[@id="pageForm"]/div[1]/div/div/div/div/div/table/tbody/tr/td[1]/a'
      wait_for_xpath(locator)
      @driver.find_elements(:xpath, locator).first.click
      # Handle modal dialog
      @driver.switch_to.alert.accept
      # Click return to pipe list
      locator = '//*[@id="pageForm"]/div[6]/div/div/div/table/tbody/tr/td[1]/a'
      wait_for_xpath(locator)
      @driver.find_elements(:xpath, locator).first.click
    end
    # Click edit
    locator = pipe_locator + "/td[6]/a"
    wait_for_xpath(locator)
    @driver.find_elements(:xpath, locator).first.click
    # Set date
    @driver.find_element(:id, "imgStartDate").click
    locator = '//*[@id="content"]/table/tbody/tr[5]/td[4]/a'
    wait_for_xpath(locator)
    @driver.find_elements(:xpath, locator).first.click
    # Save pipe
    locator = '/html/body/form/div/div[4]/div/div/div/table/tbody/tr/td[2]/table/tbody/tr/td[3]/a'
    wait_for_xpath(locator)
    @driver.find_elements(:xpath, locator).first.click
    # Click execute
    locator = pipe_locator + "/td[7]/a"
    wait_for_xpath(locator)
    @driver.find_elements(:xpath, locator).first.click
  end
  
  private
  def wait_for_css(css)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {
      (not @driver.find_elements(:css, css).first.nil?)
    }
  end

  def wait_for_xpath(xpath)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {
      (not @driver.find_elements(:xpath, xpath).first.nil?)
    }
  end
end
