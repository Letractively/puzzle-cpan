# Introduction #

Step by step guide to configure an apache virtual host with Puzzle with database,
session and pseudo-frames support.


# Prerequisites #

A /www folder for all you virtual hosts

# Configure using puzzle\_setup.pl script #

Steps "Create a Virtual Host" and "Apply Puzzle Configuration" can be jumped if you
use puzzle\_setup.pl script in mics/setup distribution directory that automatically
create a virtual host and apply puzzle configuration.

Usage: `./puzzle_setup.pl www.yourwebsite.com an_unique_tre_chars_namespace`

# Step by Step #

## Create a Virtual Host ##

```
mkdir rmw.ebruni.it
mkdir logs
mkdir www
mkdir lib
mkdir conf
```
```
cd conf/
cat > httpd.conf <<EOF
<VirtualHost rmw.ebruni.it:80>
   DocumentRoot "/www/rmw.ebruni.it/www"
   ServerName rmw.ebruni.it
   ServerAdmin info@ebruni.it
   DirectoryIndex index.mpl index.htm
   ErrorLog /www/rmw.ebruni.it/logs/error_log
   CustomLog /www/rmw.ebruni.it/logs/access_log_cmb combined
   <IfModule mod_perl.c>
      AddType text/html .mpl
      PerlSetVar ServerName "rmw.ebruni.it"
      PerlSetVar MasonErrorMode output 
      PerlSetVar MasonStaticSource 0
      <Perl>
         use lib '/var/www/rmw.ebruni.it/lib';
      </Perl>
      <FilesMatch "\.(htm|mpl|pl)$">
         SetHandler  perl-script
         PerlHandler Puzzle::MasonHandler
      </FilesMatch>
      <LocationMatch "(\.mplcom|handler|\.htt|\.yaml)$|autohandler">
         Order deny,allow 
         Deny from All
      </LocationMatch>
   </IfModule>
</VirtualHost>
EOF
```
```
mkdir /var/cache/mason/
ln -s /www/rmw.ebruni.it/conf/httpd.conf /etc/apache2/sites-enabled/rmw.ebruni.it.conf
/etc/init.d/apache2 restart
```

```
echo "Hello World" > /www/rmw.ebruni.it/www/index.htm
```

Open browser to http://rmw.ebruni.it/ and it should work.

## Apply Puzzle Configuration ##

```
cd /www/rmw.ebruni.it/www

cat > config.yaml <<EOF
frames:            0
base:              ~
frame_bottom_file: ~
frame_left_file:   ~
frame_right_file:  ~
frame_top_file:    ~
gids:          
                   - everybody
login:             /login.mpl
namespace:         rmw
description:       ""
keywords:          ""
debug:             1
cache:             0
db:
  enabled:                1
  persistent_connection:  0
  username:               rmw
  password:               YOUR_PASSWORD
  host:                   localhost
  name:                   rmw
  session_table:          sysSessions
mail:
  server:       "YOUR.SMTP.SERVER"
  from:         "YOUR@EMAIL.COM"
EOF
```

If you don't need database you can set db.enabled = 0 and remove other settings.

```
echo -e "\
<%once>\n\
\tuse Puzzle;\n\
\tuse rmw;\n\
</%once>\n\
\n\
<%init>\n\
\t\$rmw::puzzle ||= new Puzzle(cfg_path => \$m->interp->comp_root\n\
\t\t.  '/config.yaml');\n\
\t\$rmw::dbh = \$rmw::puzzle->dbh;\n\
\t\$rmw::puzzle->process_request;\n\
</%init>" > autohandler
```
```
cd ../lib

echo -e "package rmw;\n\nour \$puzzle;\nour \$dbh;\n\n1;" > rmw.pm
```

## Database configuration (Optional) ##
If you configure a database, you have also session support.

```
mysqladmin -p create rmw
```
```
echo "CREATE TABLE IF NOT EXISTS \`sysSessions\` ( \
  \`id\` varchar(32) character set latin1 collate latin1_bin NOT NULL, \
  \`a_session\` text character set latin1 collate latin1_bin, \
  \`ts\` timestamp NOT NULL default CURRENT_TIMESTAMP, \
  PRIMARY KEY  (\`id\`) \
) " | mysql -p rmw
```
```
echo "GRANT ALL PRIVILEGES ON rmw.* TO  \
 'rmw'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD'" | mysql -p rmw
```


Reload your website and nothing changes apparently but if you have enabled database
and you take a look in sysSession table you'll see a new record. It's your session.

# Do something more funny #

Now it's time to do something more funny with our module. Now we'll see how to
create, using Puzzle, a pseudo-frame website i.e. something like this


---

| Header               |

---

| Current page         |

---

| Footer               |

---


where header and footer is almost static during the navigation while current page
are pages of our website. We'll see also how to add a usefull debug window in
how html page for debug your web application.

First of all, enable frames in Puzzle framework and set base, header (top) and
footer (bottom) template by modifying first rows in config.yaml

```
frames:            1
base:              base.htt
frame_top_file:    top.htt
frame_right_file:  ~
frame_bottom_file: bottom.htt
frame_left_file:   ~
```

create a simple base template

```
base.htt

<html>
<head>
<tmpl_var name="header_client"></tmpl_var>
<tmpl_if name="debug">
        <link rel="stylesheet" type="text/css"  href="/js/debug.css">
        <script type="text/javascript" src="/js/debug.js"></script>
</tmpl_if>
<style>
#frame_top      {background-color: #6AD96A }
#frame_center   {background-color: #F2C676 }
#frame_bottom   {background-color: #C291D6 }
#frame_debug    {margin-top: 40px }
</style>
<title>Your Site Name &raquo; %title%</title>
</head>
<body %body_attributes%>
<div id="frame_top">%frame_top%</div>
<div id="frame_center">%frame_center%</div>
<div id="frame_bottom">%frame_bottom%</div>
<div id="frame_debug">%frame_debug%</div>
</body>
</html>
```

a header

```
top.htt

<html>
<head>
</head>
<body>
<h1>Your Site Name &raquo; %title%</h1>
</body>
</html>
```

a footer

```
<html>
<head>
</head>
<body>
<hr>
<div>Copyright 2011 - Your Web Site</div>
</body>
</html>
```

and two crosslinked page

```
index.htm

<html>
<head>
<title>Home Page</title>
</head>
<body>
<a href="another_page.htm">Go to another page</a>
</body>
</html>
```

and another page

```
another_page.htm

<html>
<head>
<title>Another Page</title>
</head>
<body>
<a href="index.htm">Back home</a>
</body>
</html>
```

and see the result. Sound Good?
