"""
Shared Configuration Loader
Utility to load YAML configuration files for web and mobile automation.
"""
import os
import yaml
from robot.api import logger


def load_config(config_file: str) -> dict:
    """
    Load YAML configuration file.
    
    Args:
        config_file: Path to the YAML config file
        
    Returns:
        dict: Configuration dictionary
    """
    config_path = os.path.join(
        os.path.dirname(__file__), '..', 'config', config_file
    )
    config_path = os.path.abspath(config_path)
    
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config file not found: {config_path}")
    
    with open(config_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    logger.info(f"Loaded config from: {config_path}")
    return config


def get_web_config() -> dict:
    """Get web automation configuration."""
    return load_config('web_config.yaml')


def get_mobile_config() -> dict:
    """Get mobile automation configuration."""
    return load_config('mobile_config.yaml')


def get_android_capabilities() -> dict:
    """
    Get Android desired capabilities for Appium.
    
    Returns:
        dict: Android capabilities
    """
    config = get_mobile_config()
    android = config['android']
    
    capabilities = {
        'platformName': android['platform_name'],
        'appium:platformVersion': android['platform_version'],
        'appium:deviceName': android['device_name'],
        'appium:automationName': android['automation_name'],
        'appium:appPackage': android['app_package'],
        'appium:appActivity': android['app_activity'],
        'appium:noReset': android['no_reset'],
        'appium:fullReset': android['full_reset'],
        'appium:newCommandTimeout': android['new_command_timeout'],
    }
    
    if 'app_path' in android:
        capabilities['appium:app'] = android['app_path']
    
    return capabilities


def get_ios_capabilities() -> dict:
    """
    Get iOS desired capabilities for Appium.
    
    Returns:
        dict: iOS capabilities
    """
    config = get_mobile_config()
    ios = config['ios']
    
    capabilities = {
        'platformName': ios['platform_name'],
        'appium:platformVersion': ios['platform_version'],
        'appium:deviceName': ios['device_name'],
        'appium:automationName': ios['automation_name'],
        'appium:bundleId': ios['bundle_id'],
        'appium:noReset': ios['no_reset'],
        'appium:fullReset': ios['full_reset'],
        'appium:newCommandTimeout': ios['new_command_timeout'],
    }
    
    if 'app_path' in ios:
        capabilities['appium:app'] = ios['app_path']
    
    return capabilities
