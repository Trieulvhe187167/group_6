<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Rooms</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Room Management</h1>
    
    <!-- Action Bar -->
    <div class="row mb-4">
        <div class="col-md-6">
            <a href="${pageContext.request.contextPath}/jsp/create-roomtype.jsp" 
               class="btn btn-success">
                <i class="fa fa-plus"></i> Create New Room Type
            </a>
        </div>
        <div class="col-md-6">
            <form action="${pageContext.request.contextPath}/RoomListServlet" method="get" class="form-inline float-right">
                <input name="keyword" type="text" class="form-control mr-2" 
                       placeholder="Search rooms..." value="${param.keyword}">
                <button type="submit" class="btn btn-primary">
                    <i class="fa fa-search"></i> Search
                </button>
            </form>
        </div>
    </div>
    
    <!-- Room List -->
    <div class="row">
        <c:forEach var="type" items="${roomTypes}" 
                   begin="${(currentPage - 1) * recordsPerPage}" 
                   end="${(currentPage * recordsPerPage) - 1}">
            <div class="col-lg-4 col-md-6 mb-4">
                <div class="card h-100">
                    <img src="${pageContext.request.contextPath}/assets/images/uploads/${type.imageUrl}"
                         class="card-img-top" alt="${type.name}" style="height: 200px; object-fit: cover;">
                    <div class="card-body">
                        <h5 class="card-title">${type.name}</h5>
                        <p class="card-text">
                            <i class="fas fa-users"></i> Capacity: ${type.capacity}<br>
                            <i class="fas fa-star text-warning"></i> 
                            <i class="fas fa-star text-warning"></i>
                            <i class="fas fa-star text-warning"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            (3 Reviews)
                        </p>
                        <div class="d-flex justify-content-between align-items-center">
                            <h4 class="text-primary mb-0">
                                <fmt:formatNumber value="${type.basePrice}" pattern="#,##0"/>₫
                            </h4>
                            <span class="badge badge-${type.status == 'active' ? 'success' : 'danger'}">
                                ${type.status}
                            </span>
                        </div>
                    </div>
                    <div class="card-footer">
                        <a href="${pageContext.request.contextPath}/RoomDetailServlet?id=${type.id}" 
                           class="btn btn-info btn-sm">View</a>
                        <a href="${pageContext.request.contextPath}/admin/rooms?action=edit&id=${type.id}" 
                           class="btn btn-warning btn-sm">Edit</a>
                        <a href="${pageContext.request.contextPath}/RoomListServlet?action=delete&id=${type.id}&status=inactive" 
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Are you sure?')">Delete</a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav>
            <ul class="pagination justify-content-center">
                <c:if test="${currentPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="${pageContext.request.contextPath}/RoomListServlet?page=${currentPage - 1}">
                            Previous
                        </a>
                    </li>
                </c:if>
                
                <c:forEach begin="1" end="${totalPages}" var="page">
                    <li class="page-item ${page == currentPage ? 'active' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/RoomListServlet?page=${page}">
                            ${page}
                        </a>
                    </li>
                </c:forEach>
                
                <c:if test="${currentPage < totalPages}">
                    <li class="page-item">
                        <a class="page-link" href="${pageContext.request.contextPath}/RoomListServlet?page=${currentPage + 1}">
                            Next
                        </a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </c:if>
</div>