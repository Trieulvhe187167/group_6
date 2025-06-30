<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms2">Room Management</a></li>
            <li class="breadcrumb-item active" aria-current="page">Room Detail</li>
        </ol>
    </nav>

    <!-- Room Details Card -->
    <div class="card shadow-sm">
        <div class="card-header">
            <h5 class="mb-0">Room Detail: ${room.roomNumber}</h5>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-6">
                    <label><strong>Room Number:</strong></label>
                    <p>${room.roomNumber}</p>

                    <label><strong>Status:</strong></label>
                    <p>
                        <span class="badge
                              <c:choose>
                                  <c:when test="${room.status eq 'available'}">bg-success</c:when>
                                  <c:when test="${room.status eq 'occupied'}">bg-warning</c:when>
                                  <c:when test="${room.status eq 'maintenance'}">bg-danger</c:when>
                                  <c:when test="${room.status eq 'dirty'}">bg-secondary</c:when>
                                  <c:otherwise>bg-light text-dark</c:otherwise>
                              </c:choose>
                              ">
                            ${room.status}
                        </span>
                    </p>

                    <label><strong>Room Type:</strong></label>
                    <p>${room.roomTypeName}</p>
                </div>
                <div class="col-md-6">
                    <label><strong>Capacity:</strong></label>
                    <p>${room.capacity} guests</p>

                    <label><strong>Base Price:</strong></label>
                    <p><fmt:formatNumber value="${room.basePrice}" pattern="#.##" />₫ / night</p>

                    <label><strong>Image:</strong></label>
                    <c:if test="${not empty room.imageUrl}">
                        <img src="${room.imageUrl}" class="img-fluid rounded" style="max-width: 250px;">
                    </c:if>
                    <c:if test="${empty room.imageUrl}">
                        <p class="text-muted">No image available</p>
                    </c:if>
                </div>
            </div>

            <label><strong>Description:</strong></label>
            <p>${room.roomTypeDescription}</p>

            <div class="mt-4">
                <a href="${pageContext.request.contextPath}/admin/rooms2?action=update&id=${room.id}" class="btn btn-warning text-white">
                    <i class="fas fa-edit"></i> Edit Room
                </a>
                <a href="${pageContext.request.contextPath}/admin/rooms2" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to List
                </a>
            </div>
        </div>
    </div>
</div>
