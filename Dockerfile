FROM mcr.microsoft.com/appsvc/staticsite:latest

# Copy all site files into the wwwroot served by the image
COPY site/ /home/site/wwwroot/

# Override the default nginx virtual-host config
COPY nginx.conf /etc/nginx/conf.d/default.conf
