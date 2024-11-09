# nginx.conf
events {}

http {
    upstream app_servers {
        # Define multiple app containers for load balancing
        ${app_servers}
    }

    server {
        listen 80;

        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }

    server {
        listen 8080;
        server_name 127.0.0.1;
        
        location /stub_status {
            stub_status on;
        }
    }
}
