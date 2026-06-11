# SunMao Mini Program Renovation Implementation Plan

## Summary
10 phases: backend admin CRUD, DeepSeek AI chat, shop backend/DB, mini program pages, TabBar update, cleanup.

---

## Phase 1: Backend AdminController

Create: ljx_backend/src/main/java/com/sunmao/ljx/controller/AdminController.java
Endpoints: GET /api/admin/user/list, GET /api/admin/user/search, POST /api/admin/user/add, POST /api/admin/user/update, POST /api/admin/user/delete
Uses existing UserService.register(), MyBatis-Plus LambdaQueryWrapper, existing Result wrapper.

---

## Phase 2: Backend DeepSeek AI Chat

Task 2.1: Add DeepSeek config to application.yml
Task 2.2: Create ChatService.java (HttpURLConnection + Fastjson2, JDK8 compatible)
Task 2.3: Create ChatController.java (POST /api/chat/query)
System prompt: SunMao cultural heritage expert persona.

---

## Phase 3: Backend Shop

Create: Product.java entity, ProductOrder.java entity, ProductMapper, ProductOrderMapper, ProductService, ProductServiceImpl, ProductController.
Endpoints: list, detail, search, order/create, order/my.

---

## Phase 4: Database

Execute in DBeaver: CREATE TABLE product, CREATE TABLE product_order, INSERT sample data.

---

## Phase 5: Mini Program Admin Pages

Create pages/admin/admin.* and pages/admin/admin-edit/admin-edit.*
Features: user list with search, add/edit user form, delete with confirm.

---

## Phase 6: Mini Program AI Chat Page

Create pages/chat/chat.*
Features: scrollable message bubbles, input bar, welcome message, loading state.

---

## Phase 7: Mini Program Shop Tab

Create pages/shop/shop.*
Features: category tabs (All/Furniture/Wood/Tools/Courses), product grid, search.

---

## Phase 8: Product Detail & Orders

Create pages/product/product.* and pages/order/order.*
Features: product detail with buy button, order list with status.

---

## Phase 9: My Page & TabBar

Modify my.wxml/my.js: add AI Tutor, User Management (admin only), My Orders entries.
Modify login.js: save userType to storage.
Modify app.json: register new pages, replace Dynamic with Shop in tabBar.
Delete pages/place/ directory.

---

## Phase 10: Verification

- mvn clean compile => BUILD SUCCESS
- TabBar: Home, Category, Shop, My
- Admin sees User Management
- AI chat works
- Shop products/orders work

---

## Risk Warnings

| DeepSeek Key | Configure in application.yml before testing |
| Admin role | UPDATE user SET user_type=2 manually |
| JDK 8 | ChatService uses HttpURLConnection, no external lib needed |

## Key Decisions

Admin mode, SunMao expert AI, My page entries, Shop replaces Dynamic, /api/role/entity/action URLs, adapt logic not copy code.