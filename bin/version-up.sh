if [ -z "$1" ]; then
  echo "no specified tag version." >&2
  exit 1
fi

cd /var/www/twoB
sudo -u www-data svn switch svn://192.168.0.3/devel/twoB/tags/"$1"
/etc/init.d/lighttpd restart

