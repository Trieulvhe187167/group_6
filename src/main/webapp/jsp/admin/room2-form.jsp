<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms2">Room Management</a></li>
            <li class="breadcrumb-item active">${room != null ? "Edit Room" : "Create Room"}</li>
        </ol>
    </nav>

    <!-- Title -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0">${room != null ? "Edit Room" : "Create New Room"}</h4>
    </div>

    <!-- Form Card -->
    <div class="card shadow-sm">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/rooms2">
                <input type="hidden" name="action" value="${room != null ? 'update' : 'create'}"/>
                <c:if test="${room != null}">
                    <input type="hidden" name="id" value="${room.id}" />
                </c:if>

                <!-- Room Number -->
                <div class="form-group">
                    <label for="roomNumber">Room Number <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="roomNumber" id="roomNumber"
                           value="${room != null ? room.roomNumber : ''}" required />
                </div>

                <!-- Room Type -->
                <div class="form-group">
                    <label for="roomTypeId">Room Type <span class="text-danger">*</span></label>
                    <select class="form-control" name="roomTypeId" id="roomTypeId" required>
                        <c:forEach var="rt" items="${roomTypes}">
                            <option value="${rt.id}" ${room != null && room.roomTypeId == rt.id ? 'selected' : ''}>${rt.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Status -->
                <div class="form-group">
                    <label for="status">Status <span class="text-danger">*</span></label>

                    <c:choose>
                        <c:when test="${room.status eq 'OCCUPIED' || room.status eq 'DIRTY'}">
                            <select class="form-control" name="status" id="status" disabled>
                                <option value="AVAILABLE" ${room.status eq 'AVAILABLE' ? 'selected' : ''}>Available</option>
                                <option value="OCCUPIED" ${room.status eq 'OCCUPIED' ? 'selected' : ''}>Occupied</option>
                                <option value="MAINTENANCE" ${room.status eq 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                                <option value="DIRTY" ${room.status eq 'DIRTY' ? 'selected' : ''}>Dirty</option>
                            </select>
                            <!-- Gửi status hiện tại qua form để giữ nguyên -->
                            <input type="hidden" name="status" value="${room.status}" />
                        </c:when>

                        <c:otherwise>
                            <select class="form-control" name="status" id="status" required>
                                <option value="AVAILABLE" ${room.status eq 'AVAILABLE' ? 'selected' : ''}>Available</option>
                                <option value="MAINTENANCE" ${room.status eq 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Buttons -->
                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> ${room != null ? 'Update' : 'Create'}
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/rooms2" class="btn btn-secondary ml-2">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>
