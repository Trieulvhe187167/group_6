<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle} - Housekeeper Portal</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
        }
        
        /* Header */
        .housekeeper-header {
            background: #2c3e50;
            color: white;
            padding: 15px 20px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            color: white;
            text-decoration: none;
        }
        
        .logo img {
            height: 60px;
            border-radius: 5px;
        }
        
        .logo-text {
            font-size: 20px;
            font-weight: 600;
        }
        
        /* Sidebar */
        .sidebar {
            position: fixed;
            top: 70px;
            left: 0;
            width: 250px;
            height: calc(100vh - 70px);
            background: white;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            overflow-y: auto;
            z-index: 999;
            margin-top: 10px;
        }
        
        .sidebar-nav {
            padding: 20px 0;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            padding: 12px 25px;
            color: #333;
            text-decoration: none;
            transition: all 0.3s;
            border: none;
            background: none;
            width: 100%;
            text-align: left;
            cursor: pointer;
        }
        
        .nav-item:hover {
            background: #f8f9fa;
            color: #2c3e50;
            text-decoration: none;
        }
        
        .nav-item.active {
            background: #2c3e50;
            color: white;
        }
        
        .nav-item i {
            width: 20px;
            margin-right: 10px;
        }
        
        /* Main Content */
        .main-content {
            margin-left: 250px;
            margin-top: 70px;
            padding: 30px;
            min-height: calc(100vh - 70px);
        }
        
        /* Common Styles */
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-icon {
            font-size: 40px;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .task-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            transition: all 0.3s;
        }
        
        .task-card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .table-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .status-badge {
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-in-progress {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .status-done {
            background: #d4edda;
            color: #155724;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="housekeeper-header">
        <div class="d-flex align-items-center">
            <button class="btn btn-link text-white d-md-none" onclick="toggleSidebar()">
                <i class="fas fa-bars"></i>
            </button>
            <a href="${pageContext.request.contextPath}/housekeeper-dashboard" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Logo">
                <span class="logo-text">Housekeeper Portal</span>
            </a>
        </div>
        
        <div class="d-flex align-items-center">
            <span class="mr-3">Welcome, ${sessionScope.user.fullName}</span>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>
    
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/housekeeper-dashboard" 
               class="nav-item ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks" 
               class="nav-item ${activePage == 'tasks' ? 'active' : ''}">
                <i class="fas fa-list-alt"></i> My Tasks
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=PENDING" 
               class="nav-item ${activePage == 'pending' ? 'active' : ''}">
                <i class="fas fa-clock"></i> Pending Tasks
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=IN_PROGRESS" 
               class="nav-item ${activePage == 'in-progress' ? 'active' : ''}">
                <i class="fas fa-spinner"></i> In Progress
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=DONE" 
               class="nav-item ${activePage == 'completed' ? 'active' : ''}">
                <i class="fas fa-check-circle"></i> Completed Tasks
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/reports" 
               class="nav-item ${activePage == 'reports' ? 'active' : ''}">
                <i class="fas fa-chart-bar"></i> My Reports
            </a>
            <a href="${pageContext.request.contextPath}/housekeeper/profile" 
               class="nav-item ${activePage == 'profile' ? 'active' : ''}">
                <i class="fas fa-user"></i> My Profile
            </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <jsp:include page="${contentPage}" />
    </main>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
        }
        
        // Set greeting based on time
        $(document).ready(function() {
            var hour = new Date().getHours();
            var greeting;
            
            if (hour < 12) {
                greeting = "morning";
            } else if (hour < 18) {
                greeting = "afternoon";  
            } else {
                greeting = "evening";
            }
        });
    </script>
</body>
</html>