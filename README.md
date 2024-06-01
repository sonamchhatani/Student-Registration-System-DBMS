Project Configuration Guide
Database Configuration
Author: Luoxi Tang,Sonam Chhatani
The database configuration file is located at src/main/resources/application.yaml. Please fill in your Oracle database configuration as follows:

```yaml
spring:
  datasource:
    driver-class-name: Configure driver, use Oracle driver
    username: Enter Oracle username
    password: Enter Oracle password
    url: URL to connect to the database

server:
  port: Set the backend port number
  servlet:
    context-path: Set the access path for the project

```pom.xml
<<dependencies>
    <!-- Spring Boot Web Dependency -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Oracle Database Driver -->
    <dependency>
        <groupId>com.oracle.database.jdbc</groupId>
        <artifactId>ojdbc11</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- Lombok Dependency, for automatically generating getters and setters -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

    <!-- Spring Boot Test Dependency -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- MyBatis-Plus Dependency -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
        <version>3.5.5</version>
    </dependency>
</dependencies>

---

# Vue 3 + TypeScript + Vite

This template should help you get started developing with Vue 3 and TypeScript in Vite. The template uses Vue 3 `<script setup>` SFCs. Check out the [script setup docs](https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup) to learn more.

## Recommended Setup

- [VS Code](https://code.visualstudio.com/) + [Vue - Official](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (previously Volar) and disable Vetur

- Use [vue-tsc](https://github.com/vuejs/language-tools/tree/master/packages/tsc) for performing the same type checking from the command line, or for generating d.ts files for SFCs.

## Using the Element-Plus Component Library

## Runtime Environment
- node18.18.1
- webstorm (compilation software)

# All the following folders are located under the src folder

## Route Configuration
- Store routes in router/index.ts

## Page Structure
- The page structure is defined in layout, which includes the left navigation bar, the top navigation bar, and the content part.

## Type Definitions
- Data types are defined in models

## Page Content
- Page content is written in views

---

