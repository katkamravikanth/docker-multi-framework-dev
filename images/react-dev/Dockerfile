FROM node:24-alpine

LABEL maintainer="Ravikanth Katkam"
LABEL description="Reusable Node 24 Alpine image for React development"

# Install additional tools if needed
RUN apk add --no-cache git

# Set working directory (can be overridden in docker-compose)
WORKDIR /app

# Expose common React dev server port
EXPOSE 3000 5173

# Default command (can be overridden in docker-compose)
CMD ["npm", "run", "dev"]
