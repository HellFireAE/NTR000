<?php

/**
 * Configuration overrides for WP_ENV === 'development'
 */

use Roots\WPConfig\Config;

use function Env\env;

// Performance-optimized development settings
Config::define('SAVEQUERIES', false); // Major performance killer - enable only when debugging queries
Config::define('WP_DEBUG', true); // Keep debug mode on
Config::define('WP_DEBUG_LOG', false); // Disable file logging for better performance
Config::define('WP_DEBUG_DISPLAY', true); // Show errors on screen
Config::define('WP_DISABLE_FATAL_ERROR_HANDLER', false); // Let WordPress handle fatal errors properly
Config::define('SCRIPT_DEBUG', false); // Use minified scripts for better performance
Config::define('DISALLOW_INDEXING', true);

// Note: PHP is configured to show only E_ERROR and E_PARSE (fatal/critical errors)
// To see warnings/notices, edit .devcontainer/php/php.ini and change error_reporting

// Enable plugin and theme updates and installation from the admin
Config::define('DISALLOW_FILE_MODS', false);
