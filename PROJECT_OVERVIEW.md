Mess Management System
Smart Food Subscription & Pickup Platform
1. Project Overview
The Mess Management System is a digital platform designed to simplify how students and working individuals subscribe to daily meals from local mess providers.

In many cities, especially college areas, students rely on mess services for daily food. However, the current system has several problems:

No digital ordering system

Food wastage due to uncertain demand

Manual payment handling

No clear tracking of meals

No structured pickup management

This project solves these issues by creating a modern platform where users can discover mess providers, subscribe to meal plans, order meals, and pick them up from designated pickup points.

The system consists of three main components:

User Application

Mess Owner Application

Admin Panel

2. Problem Statement
Traditional mess systems operate manually and face several challenges:

1. Food Wastage
Mess owners prepare food without knowing the exact number of customers.

2. No Order Tracking
Students cannot track if their food is ready.

3. Manual Payments
Cash payments create accounting issues.

4. Pickup Chaos
Many students arrive at the same time causing crowding.

5. Poor Communication
Users cannot easily contact the mess owner or report issues.

3. Solution
The Mess Management System provides a structured digital solution where:

Users can:

Discover nearby mess services

View daily menus

Place meal orders

Select pickup points

Pay using wallet

Track orders

Setup auto reorder

Mess owners can:

Upload daily menus

Manage meal quantities

View orders

Manage pickup points

Track earnings

Admins can:

Approve mess owners

Manage system operations

Monitor transactions

Resolve disputes

4. Target Users
Primary Users
College students

Hostel residents

Working professionals

Secondary Users
Mess owners

Cloud kitchen operators

Small food providers

Admin Users
Platform management team

5. System Architecture
The platform consists of three main systems.

User App
     $\downarrow$
Backend API Server
     $\downarrow$
Database
     $\downarrow$
Owner App
     $\downarrow$
Admin Panel
Technologies Used
Component	Technology
Mobile App	Flutter
Backend	Node.js / Django / Spring (flexible)
Database	PostgreSQL / MongoDB
Authentication	JWT / Firebase
Payment System	Wallet + Payment Gateway
Storage	Cloud Storage
6. Core Features
6.1 User App Features
1. Location Detection
Detect nearby mess providers using location.

2. Mess Discovery
Users can browse available mess services.

3. Mess Profile View
Shows:

Mess name

Photos

Menu

Ratings

Location

Pricing

4. Menu Browsing
Users can view:

Breakfast
Lunch
Dinner

Daily or weekly menus.

5. Order Placement
Users can order meals.

Example:

Breakfast - 1
Lunch - 1
Dinner - 0
6. Pickup Point Selection
Users select where to collect their food.

Example pickup points:

Hostel Gate

College Parking

Apartment Entrance

7. Wallet Payments
Users recharge wallet and pay instantly.

8. Order Tracking
Users can track:

Order Placed
Preparing
Ready for Pickup
Completed
9. Auto Reorder
Users can setup automatic ordering.

Example:

Lunch daily
Dinner Mon-Fri
10. Order History
Users can see past orders.

11. Help & Support
Users can contact support or report issues.

7. Mess Owner App Features
7.1 Mess Registration
Owners must register and get admin approval.

Mess Setup Includes:
Mess name

Address

Photos

Contact number

Operating hours

7.2 Menu Management
Owners upload menus for:

Breakfast
Lunch
Dinner
They can also update menu items daily.

7.3 Quantity Control
Owners define how many meals are available.

Example:

Breakfast : 80 plates
Lunch : 150 plates
Dinner : 120 plates
When quantity reaches zero $\rightarrow$ ordering stops automatically.

7.4 Order Management
Owners can see:

Today's orders
Pickup points
Customer details
Meal counts
7.5 Pickup Point Management
Owners define where users will collect meals.

Example:

Point 1: College Gate
Point 2: Hostel Block A
Point 3: Apartment Gate
7.6 Revenue Tracking
Owners can track:

Daily earnings

Weekly earnings

Monthly earnings

7.7 Wallet Settlement
Payments collected from users go to the owner wallet.

8. Admin Panel Features
Admins manage the entire platform.

Admin Controls
Approve mess owners

Manage pickup points

Monitor transactions

View system analytics

Handle disputes

Suspend accounts if necessary

9. Order Flow
Example user order process:

User opens app
      $\downarrow$
Select mess
      $\downarrow$
View menu
      $\downarrow$
Select meal
      $\downarrow$
Select pickup point
      $\downarrow$
Pay using wallet
      $\downarrow$
Order confirmed
      $\downarrow$
Mess prepares food
      $\downarrow$
User picks up food
10. Payment System
The platform uses a wallet-based payment system.

Wallet Flow
User adds money to wallet
       $\downarrow$
User places order
       $\downarrow$
Wallet balance deducted
       $\downarrow$
Amount credited to mess owner
11. Database Main Entities
Key data models include:

Users

Mess Owners

Mess Profiles

Menus

Orders

Pickup Points

Wallet Transactions

Payments

Reviews

12. Security Features
Authentication system

Secure payments

Fraud detection

Owner verification

Data encryption

13. Future Enhancements
Subscription plans

Meal rating system

AI-based demand prediction

Smart pickup scheduling

Delivery integration

Nutrition tracking

14. Real World Impact
This system will help:

Students get reliable meals

Mess owners reduce food waste

Improve operational efficiency

Provide structured food distribution

Create a scalable food platform

15. Project Goal
The goal of this project is to build a production-level food subscription and pickup management system that can scale across colleges and cities.

It aims to modernize the traditional mess ecosystem using technology.