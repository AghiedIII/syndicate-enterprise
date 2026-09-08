FROM node:18-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build application (in production)
# RUN npm run build

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "run", "start:dev"]
