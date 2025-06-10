<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Housekeeper Dashboard - Luxury Hotel</title>
    
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
            background: #f8f9fa;
        }
        
        /* Header */
        .dashboard-header {
            background: #2c3e50;
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .logo img {
            height: 100px;
            
            padding: 5px;
            border-radius: 5px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        /* Main Content */
        .main-content {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        /* Dashboard Cards */
        .dashboard-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s;
        }
        
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        
        .stat-card {
            text-align: center;
            padding: 20px;
        }
        
        .stat-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.8;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .action-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            border: 2px solid transparent;
        }
        
        .action-card:hover {
            border-color: #2c3e50;
            transform: translateY(-3px);
            text-decoration: none;
            color: inherit;
        }
        
        .action-icon {
            font-size: 36px;
            margin-bottom: 10px;
        }
        
        /* Task List */
        .task-item {
            border-bottom: 1px solid #e9ecef;
            padding: 15px 0;
        }
        
        .task-item:last-child {
            border-bottom: none;
        }
        
        .room-number {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .task-status {
            display: inline-block;
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
        
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .stat-number {
                font-size: 28px;
            }
            
            .quick-actions {
                grid-template-columns: 1fr 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="dashboard-header">
        <div class="header-content">
          
            <div class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Logo">
                <h3 class="mb-0">Housekeeper Portal</h3>
            </div>
            
            <div class="user-info">
                <span>Welcome, ${currentUser.fullName}</span>
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </header>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Welcome Section -->
        <div class="mb-4">
            <h1>Good ${sessionScope.greeting}, ${currentUser.fullName}!</h1>
            <p class="text-muted">Here's your work summary for today</p>
        </div>
        
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="dashboard-card stat-card">
                    <div class="stat-icon text-warning">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-number">${stats.pendingCount}</div>
                    <div class="stat-label">Pending Tasks</div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="dashboard-card stat-card">
                    <div class="stat-icon text-info">
                        <i class="fas fa-spinner"></i>
                    </div>
                    <div class="stat-number">${stats.inProgressCount}</div>
                    <div class="stat-label">In Progress</div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="dashboard-card stat-card">
                    <div class="stat-icon text-success">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-number">${stats.todayCompletedCount}</div>
                    <div class="stat-label">Completed Today</div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="dashboard-card stat-card">
                    <div class="stat-icon text-primary">
                        <i class="fas fa-tasks"></i>
                    </div>
                    <div class="stat-number">${stats.totalTasks}</div>
                    <div class="stat-label">Total Tasks</div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <h2 class="mb-3">Quick Actions</h2>
        <div class="quick-actions mb-4">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="action-card">
                <div class="action-icon text-primary">
                    <i class="fas fa-list-alt"></i>
                </div>
                <h5>View All Tasks</h5>
                <p class="text-muted mb-0">See all assigned tasks</p>
            </a>
            
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=PENDING" class="action-card">
                <div class="action-icon text-warning">
                    <i class="fas fa-exclamation-circle"></i>
                </div>
                <h5>Pending Tasks</h5>
                <p class="text-muted mb-0">${stats.pendingCount} tasks waiting</p>
            </a>
            
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=IN_PROGRESS" class="action-card">
                <div class="action-icon text-info">
                    <i class="fas fa-play-circle"></i>
                </div>
                <h5>Active Tasks</h5>
                <p class="text-muted mb-0">${stats.inProgressCount} in progress</p>
            </a>
            
            <a href="${pageContext.request.contextPath}/housekeeper/report" class="action-card">
                <div class="action-icon text-success">
                    <i class="fas fa-chart-bar"></i>
                </div>
                <h5>My Reports</h5>
                <p class="text-muted mb-0">View work reports</p>
            </a>
        </div>
        
        <!-- Recent Tasks -->
        <div class="row">
            <div class="col-md-8">
                <div class="dashboard-card">
                    <h3 class="mb-4">Recent Tasks</h3>
                    
                    <c:choose>
                        <c:when test="${not empty recentTasks}">
                            <c:forEach var="task" items="${recentTasks}">
                                <div class="task-item">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <span class="room-number">Room ${task.roomNumber}</span>
                                            <span class="ml-2 text-muted">${task.roomTypeName}</span>
                                            <p class="mb-0 mt-1 text-muted">
                                                <c:choose>
                                                    <c:when test="${not empty task.notes}">
                                                        ${task.notes.length() > 50 ? task.notes.substring(0, 50).concat('...') : task.notes}
                                                    </c:when>
                                                    <c:otherwise>
                                                        No special instructions
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="text-right">
                                            <span class="task-status status-${task.status.toLowerCase().replace('_', '-')}">
                                                ${task.statusDisplayName}
                                            </span>
                                            <p class="mb-0 mt-2">
                                                <a href="${pageContext.request.contextPath}/housekeeper/task-detail?id=${task.id}" 
                                                   class="btn btn-sm btn-outline-primary">
                                                    View Details
                                                </a>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <div class="text-center mt-4">
                                <a href="${pageContext.request.contextPath}/housekeeper/tasks" 
                                   class="btn btn-primary">
                                    View All Tasks
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <i class="fas fa-clipboard-check fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No tasks assigned yet</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <div class="col-md-4">
                <!-- Today's Summary -->
                <div class="dashboard-card mb-3">
                    <h4 class="mb-3">Today's Summary</h4>
                    <div class="mb-3">
                        <small class="text-muted">Date</small>
                        <p class="mb-0 font-weight-bold">
                            <fmt:formatDate value="<%=new java.util.Date()%>" pattern="EEEE, dd MMMM yyyy"/>
                        </p>
                    </div>
                    <div class="mb-3">
                        <small class="text-muted">Working Hours</small>
                        <p class="mb-0 font-weight-bold">8:00 AM - 5:00 PM</p>
                    </div>
                    <div>
                        <small class="text-muted">Completed Today</small>
                        <p class="mb-0 font-weight-bold">${stats.todayCompletedCount} tasks</p>
                    </div>
                </div>
                
                <!-- Notifications -->
                <div class="dashboard-card">
                    <h4 class="mb-3">Notifications</h4>
                    <div class="text-center py-4">
                        <i class="fas fa-bell fa-2x text-muted mb-2"></i>
                        <p class="text-muted mb-0">No new notifications</p>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
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
            
            sessionStorage.setItem('greeting', greeting);
        });
    </script>
</body>
</html>