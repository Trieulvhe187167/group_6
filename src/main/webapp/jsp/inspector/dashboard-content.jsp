<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Dashboard</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Room Inspector Dashboard</h1>
    
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
    
    <!-- Stats Cards -->
    <div class="row">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-primary">
                    <i class="fas fa-clipboard-check"></i>
                </div>
                <div class="stat-number">${stats.totalInspections}</div>
                <div class="stat-label">Total Inspections</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-warning">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number">${stats.pendingInspections}</div>
                <div class="stat-label">Pending Reviews</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-success">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="stat-number">${stats.completedToday}</div>
                <div class="stat-label">Completed Today</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-info">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <div class="stat-number">
                    <fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0"/>₫
                </div>
                <div class="stat-label">Total Charges Found</div>
            </div>
        </div>
    </div>
    
    <!-- Pending Inspections -->
    <div class="card mt-4">
        <div class="card-header bg-warning text-white">
            <h5 class="mb-0">
                <i class="fas fa-exclamation-triangle"></i> Rooms Awaiting Inspection
            </h5>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${not empty pendingInspections}">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Room</th>
                                    <th>Guest Name</th>
                                    <th>Check-out Date</th>
                                    <th>Stay Duration</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="reservation" items="${pendingInspections}">
                                    <tr>
                                        <td>
                                            <strong>${reservation.roomNumber}</strong>
                                            <br>
                                            <small class="text-muted">${reservation.roomTypeName}</small>
                                        </td>
                                        <td>
                                            ${reservation.customerName}
                                            <br>
                                            <small class="text-muted">${reservation.customerPhone}</small>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/>
                                            <br>
                                            <c:choose>
                                                <c:when test="${reservation.checkOut < today}">
                                                    <small class="text-danger">Overdue</small>
                                                </c:when>
                                                <c:when test="${reservation.checkOut == today}">
                                                    <small class="text-warning">Today</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <small class="text-info">Upcoming</small>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:set var="days" value="${(reservation.checkOut.time - reservation.checkIn.time) / (1000*60*60*24)}"/>
                                            ${days} nights
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/inspector/inspection?action=start&reservationId=${reservation.id}" 
                                               class="btn btn-primary btn-sm">
                                                <i class="fas fa-clipboard-check"></i> Start Inspection
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="fas fa-check-circle fa-3x text-success mb-3"></i>
                        <p class="text-muted">No pending inspections at the moment.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <!-- Recent Inspections -->
    <div class="card mt-4">
        <div class="card-header">
            <h5 class="mb-0">
                <i class="fas fa-history"></i> My Recent Inspections
            </h5>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${not empty myInspections}">
                    <div class="row">
                        <c:forEach var="inspection" items="${myInspections}" begin="0" end="5">
                            <div class="col-md-6 mb-3">
                                <div class="inspection-card">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            <h6 class="mb-1">Room ${inspection.reservation.roomNumber}</h6>
                                            <small class="text-muted">
                                                ${inspection.reservation.customerName}
                                            </small>
                                        </div>
                                        <span class="room-condition-badge condition-${inspection.roomCondition.toLowerCase()}">
                                            ${inspection.roomCondition}
                                        </span>
                                    </div>
                                    
                                    <div class="row mt-3">
                                        <div class="col-6">
                                            <small class="text-muted">Inspection Date</small>
                                            <br>
                                            <fmt:formatDate value="${inspection.inspectionTime}" pattern="dd/MM/yyyy HH:mm"/>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted">Total Charges</small>
                                            <br>
                                            <strong class="text-danger">
                                                <fmt:formatNumber value="${inspection.totalCharges}" pattern="#,##0"/>₫
                                            </strong>
                                        </div>
                                    </div>
                                    
                                    <div class="mt-3">
                                        <c:choose>
                                            <c:when test="${inspection.status == 'PENDING'}">
                                                <span class="badge badge-warning">Pending Approval</span>
                                                <a href="${pageContext.request.contextPath}/inspector/inspection?action=edit&id=${inspection.id}" 
                                                   class="btn btn-sm btn-warning ml-2">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>
                                            </c:when>
                                            <c:when test="${inspection.status == 'COMPLETED'}">
                                                <span class="badge badge-success">Completed</span>
                                            </c:when>
                                        </c:choose>
                                        <a href="${pageContext.request.contextPath}/inspector/inspection?action=view&id=${inspection.id}" 
                                           class="btn btn-sm btn-outline-primary float-right">
                                            View Details
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <div class="text-center mt-3">
                        <a href="${pageContext.request.contextPath}/inspector/my-inspections" 
                           class="btn btn-primary">
                            View All Inspections
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4">
                        <i class="fas fa-clipboard fa-3x text-muted mb-3"></i>
                        <p class="text-muted">No inspections completed yet.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>