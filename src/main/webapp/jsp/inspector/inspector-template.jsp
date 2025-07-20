<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle} - Room Inspector</title>
    
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
        .inspector-header {
            background: #28a745;
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
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            color: white;
            text-decoration: none;
        }
        
        .logo img {
            height: 40px;
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
            color: #28a745;
            text-decoration: none;
        }
        
        .nav-item.active {
            background: #28a745;
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
        
        /* Cards */
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.2s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
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
        
        .inspection-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: all 0.3s;
        }
        
        .inspection-card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }
        
        .room-condition-badge {
            font-size: 14px;
            padding: 5px 10px;
            border-radius: 20px;
        }
        
        .condition-excellent { background: #d4edda; color: #155724; }
        .condition-good { background: #cce5ff; color: #004085; }
        .condition-fair { background: #fff3cd; color: #856404; }
        .condition-poor { background: #f8d7da; color: #721c24; }
        .condition-damaged { background: #f5c6cb; color: #721c24; }
        
        /* Forms */
        .inspection-form {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .cleanliness-rating {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .cleanliness-rating input[type="radio"] {
            display: none;
        }
        
        .cleanliness-rating label {
            cursor: pointer;
            font-size: 24px;
            color: #ddd;
            transition: color 0.2s;
        }
        
        .cleanliness-rating input[type="radio"]:checked ~ label,
        .cleanliness-rating label:hover,
        .cleanliness-rating label:hover ~ label {
            color: #ffc107;
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
    <header class="inspector-header">
        <div class="d-flex align-items-center">
            <button class="btn btn-link text-white d-md-none" onclick="toggleSidebar()">
                <i class="fas fa-bars"></i>
            </button>
            <a href="${pageContext.request.contextPath}/inspector/dashboard" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Logo">
                <span class="logo-text">Room Inspector</span>
            </a>
        </div>
        
        <div class="d-flex align-items-center">
            <span class="mr-3">
                <i class="fas fa-user-check"></i> ${sessionScope.user.fullName}
            </span>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>
    
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/inspector/dashboard" 
               class="nav-item ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/inspector/pending-inspections" 
               class="nav-item ${activePage == 'pending-inspections' ? 'active' : ''}">
                <i class="fas fa-clipboard-list"></i> Pending Inspections
            </a>
            <a href="${pageContext.request.contextPath}/inspector/my-inspections" 
               class="nav-item ${activePage == 'myInspections' ? 'active' : ''}">
                <i class="fas fa-history"></i> My Inspections
            </a>
            <a href="${pageContext.request.contextPath}/inspector/reports" 
               class="nav-item ${activePage == 'reports' ? 'active' : ''}">
                <i class="fas fa-chart-bar"></i> Reports
            </a>
                  <a href="${pageContext.request.contextPath}/inspector/profile"
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
        
        // Toast notification
        function showToast(message, type) {
            // Set default type if not provided
            if (!type) {
                type = 'success';
            }
            
            // Determine header text based on type
            var headerText = (type === 'success') ? 'Success' : 'Error';
            
            // Create toast HTML
            var toastHtml = '<div class="toast" role="alert" style="position: fixed; top: 80px; right: 20px; z-index: 9999;">' +
                           '<div class="toast-header bg-' + type + ' text-white">' +
                           '<strong class="mr-auto">' + headerText + '</strong>' +
                           '<button type="button" class="ml-2 mb-1 close text-white" data-dismiss="toast">' +
                           '<span>&times;</span>' +
                           '</button>' +
                           '</div>' +
                           '<div class="toast-body">' +
                           message +
                           '</div>' +
                           '</div>';
            
            var toast = $(toastHtml);
            
            $('body').append(toast);
            toast.toast({ delay: 3000 }).toast('show');
            
            toast.on('hidden.bs.toast', function() {
                $(this).remove();
            });
        }
    </script>
</body>
</html>