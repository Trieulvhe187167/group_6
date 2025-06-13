<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Tasks - Housekeeper Portal</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f8f9fa;
        }
        
        .header {
            background: #2c3e50;
            color: white;
            padding: 20px 0;
            margin-bottom: 30px;
        }
        
        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
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
        
        .room-badge {
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
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
        
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        
        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container-custom">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3 class="mb-0">My Tasks</h3>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-0 bg-transparent p-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard" class="text-white">Dashboard</a></li>
                            <li class="breadcrumb-item active text-white-50">My Tasks</li>
                        </ol>
                    </nav>
                </div>
                <a href="${pageContext.request.contextPath}/housekeeper-dashboard" class="btn btn-outline-light">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </header>
    
    <div class="container-custom">
        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${sessionScope.success}
                <button type="button" class="close" data-dismiss="alert">
                    <span>&times;</span>
                </button>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        
        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${sessionScope.error}
                <button type="button" class="close" data-dismiss="alert">
                    <span>&times;</span>
                </button>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>
        
        <!-- Filter Section -->
        <div class="filter-section">
            <form method="get" action="${pageContext.request.contextPath}/housekeeper/tasks" class="form-inline">
                <div class="form-group mr-3">
                    <label class="mr-2">Status:</label>
                    <select name="status" class="form-control" onchange="this.form.submit()">
                        <option value="ALL" ${status == 'ALL' || empty status ? 'selected' : ''}>All Tasks</option>
                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="IN_PROGRESS" ${status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                        <option value="DONE" ${status == 'DONE' ? 'selected' : ''}>Completed</option>
                    </select>
                </div>
                
                <div class="form-group mr-3">
                    <label class="mr-2">Search:</label>
                    <input type="text" name="search" class="form-control" 
                           placeholder="Room number..." value="${search}">
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-filter"></i> Filter
                </button>
                
                <c:if test="${not empty status && status != 'ALL' || not empty search}">
                    <a href="${pageContext.request.contextPath}/housekeeper/tasks" 
                       class="btn btn-secondary ml-2">
                        <i class="fas fa-times"></i> Clear
                    </a>
                </c:if>
            </form>
        </div>
        
        <!-- Tasks List -->
        <c:choose>
            <c:when test="${not empty tasks}">
                <c:forEach var="task" items="${tasks}">
                    <div class="task-card">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <div class="d-flex align-items-center mb-2">
                                    <span class="room-badge">Room ${task.roomNumber}</span>
                                    <span class="ml-3 text-muted">${task.roomTypeName}</span>
                                    <span class="ml-3 status-badge status-${task.status.toLowerCase().replace('_', '-')}">
                                        ${task.statusDisplayName}
                                    </span>
                                </div>
                                
                                <p class="mb-2">
                                    <i class="fas fa-clipboard text-muted mr-2"></i>
                                    <c:choose>
                                        <c:when test="${not empty task.notes}">
                                            ${task.notes}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No special instructions</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                
                                <small class="text-muted">
                                    <i class="fas fa-clock mr-1"></i>
                                    Created: <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    <c:if test="${task.status == 'DONE'}">
                                        | Completed: <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:if>
                                </small>
                            </div>
                            
                            <div class="col-md-4">
                                <div class="action-buttons justify-content-end">
                                    <a href="${pageContext.request.contextPath}/housekeeper/task-detail?id=${task.id}" 
                                       class="btn btn-info btn-sm">
                                        <i class="fas fa-eye"></i> View Details
                                    </a>
                                    
                                    <c:if test="${task.status != 'DONE'}">
                                        <c:choose>
                                            <c:when test="${task.status == 'PENDING'}">
                                                <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" style="display: inline;">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="taskId" value="${task.id}">
                                                    <input type="hidden" name="status" value="IN_PROGRESS">
                                                    <button type="submit" class="btn btn-warning btn-sm">
                                                        <i class="fas fa-play"></i> Start
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:when test="${task.status == 'IN_PROGRESS'}">
                                                <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" style="display: inline;">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="taskId" value="${task.id}">
                                                    <input type="hidden" name="status" value="DONE">
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        <i class="fas fa-check"></i> Complete
                                                    </button>
                                                </form>
                                            </c:when>
                                        </c:choose>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&status=${status}&search=${search}">
                                    Previous
                                </a>
                            </li>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&status=${status}&search=${search}">
                                        ${i}
                                    </a>
                                </li>
                            </c:forEach>
                            
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&status=${status}&search=${search}">
                                    Next
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-clipboard-list fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No tasks found</h4>
                    <p class="text-muted">You don't have any tasks matching the selected criteria.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>