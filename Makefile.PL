use inc::Module::Install;

name       'Jifty-Plugin-Authentication-Twitter';
all_from   'lib/Jifty/Plugin/Authentication/Twitter.pm';
repository 'http://github.com/bestpractical/jifty-plugin-authentication-twitter';

requires('Jifty');

WriteAll;
