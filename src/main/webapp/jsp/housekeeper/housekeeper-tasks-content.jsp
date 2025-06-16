<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard">Home</a></li>
            <li class="breadcrumb-item active">My Tasks</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">My Tasks</h1>
    
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
    <div class="card mb-4">
        <div class="card-body">
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
    </div>
    
    <!-- Tasks List -->
    <c:choose>
        <c:when test="${not empty tasks}">
            <c:forEach var="task" items="${tasks}">
                <div class="task-card">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <div class="d-flex align-items-center mb-2">
                                <h4 class="mb-0">Room ${task.roomNumber}</h4>
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
                            <div class="text-right">
                                <a href="${pageContext.request.contextPath}/housekeeper/task-detail?id=${task.id}" 
                                   class="btn btn-info btn-sm">
                                    <i class="fas fa-eye"></i> View Details
                                </a>
                                
                                <c:if test="${task.status != 'DONE'}">
                                    <c:choose>
                                        <c:when test="${task.status == 'PENDING'}">
                                            <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" 
                                                  style="display: inline;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="taskId" value="${task.id}">
                                                <input type="hidden" name="status" value="IN_PROGRESS">
                                                <button type="submit" class="btn btn-warning btn-sm">
                                                    <i class="fas fa-play"></i> Start
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${task.status == 'IN_PROGRESS'}">
                                            <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" 
                                                  style="display: inline;">
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