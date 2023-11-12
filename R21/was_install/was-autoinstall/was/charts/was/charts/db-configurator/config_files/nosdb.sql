CREATE DATABASE IF NOT EXISTS __USERNAME__ CHARACTER SET UTF8MB4;
CREATE USER IF NOT EXISTS '__USERNAME__'@'%' IDENTIFIED BY '__PASSWORD__';
ALTER USER '__USERNAME__'@'%'  IDENTIFIED BY '__PASSWORD__';
GRANT ALL PRIVILEGES ON __USERNAME__.* TO '__USERNAME__'@'%' REQUIRE SSL;
FLUSH PRIVILEGES;