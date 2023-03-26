# Textly feed service 📩

# Feed service for textly

Features:


Build: 

1. Create .env file with 
      - SECRET_KEY
      - PROFILES_PORT
      - PROFILES_HOST
      - PROFILES_DATABASE_HOST
      - PROFILES_DATABASE_PORT
      - PROFILES_DATABASE_NAME
      - PROFILES_DATABASE_USERNAME
      - PROFILES_DATABASE_PASSWORD
      - POSTS_PORT
      - POSTS_HOST
      - POSTS_DATABASE_HOST
      - POSTS_DATABASE_PORT
      - POSTS_DATABASE_NAME
      - POSTS_DATABASE_USERNAME
      - POSTS_DATABASE_PASSWORD

2. Build server.dart with dart_frog
```
dart_frog build
```

3. Copy root Dockerfile to ./build/

4. Docker build --ssh Default or Docker compose build --ssh Default 

5. docker run or docker compose up