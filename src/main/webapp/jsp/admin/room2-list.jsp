<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Room Management</li>
        </ol>
    </nav>

    <!-- Alerts -->
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success">${sessionScope.success}</div>
        <c:remove var="success" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger">${sessionScope.error}</div>
        <c:remove var="error" scope="session"/>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <!-- Filter Form -->
    <div class="card mb-3">
        <div class="card-body">
            <form method="get" class="form-inline" action="${pageContext.request.contextPath}/admin/rooms2">
                <input type="text" name="keyword" value="${keyword}" placeholder="Search room number" class="form-control mr-2"/>

                <select name="roomTypeId" class="form-control mr-2">
                    <option value="">All Room Types</option>
                    <c:forEach var="rt" items="${roomTypes}">
                        <option value="${rt.id}" ${selectedRoomTypeId == rt.id ? 'selected' : ''}>${rt.name}</option>
                    </c:forEach>
                </select>

                <select name="capacity" class="form-control mr-2">
                    <option value="">All Capacities</option>
                    <option value="1" ${selectedCapacity == 1 ? 'selected' : ''}>1 person</option>
                    <option value="2" ${selectedCapacity == 2 ? 'selected' : ''}>2 people</option>
                    <option value="3" ${selectedCapacity == 3 ? 'selected' : ''}>3+ people</option>
                </select>

                <select name="status" class="form-control mr-2">
                    <option value="">All Status</option>
                    <option value="available" ${selectedStatus == 'available' ? 'selected' : ''}>Available</option>
                    <option value="occupied" ${selectedStatus == 'occupied' ? 'selected' : ''}>Occupied</option>
                    <option value="maintenance" ${selectedStatus == 'maintenance' ? 'selected' : ''}>Maintenance</option>
                    <option value="dirty" ${selectedStatus == 'dirty' ? 'selected' : ''}>Dirty</option>
                </select>

                <button type="submit" class="btn btn-primary">Filter</button>

                <c:if test="${not empty keyword || selectedRoomTypeId != null || selectedCapacity != null || selectedStatus != null}">
                    <a href="${pageContext.request.contextPath}/admin/rooms2" class="btn btn-secondary ml-2">Clear</a>
                </c:if>

                <a href="${pageContext.request.contextPath}/admin/rooms2?action=form" class="btn btn-success ml-auto">
                    <i class="fas fa-plus"></i> Add Room
                </a>
            </form>
        </div>
    </div>

    <!-- Room Table -->
    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="thead-light">
                        <tr>
                            <th>#</th>
                            <th>Room Number</th>
                            <th>Room Type</th>
                            <th>Capacity</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="room" items="${rooms}" varStatus="status">
                            <tr>
                                <td>${(currentPage - 1) * recordsPerPage + status.index + 1}</td>
                                <td>${room.roomNumber}</td>
                                <td>${room.roomTypeName}</td>
                                <td>${room.capacity}</td>
                                <td><fmt:formatNumber value="${room.basePrice}" pattern="#,##0"/>₫</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${fn:toLowerCase(room.status) == 'available'}">
                                            <span class="badge bg-success text-white">Available</span>
                                        </c:when>
                                        <c:when test="${fn:toLowerCase(room.status) == 'occupied'}">
                                            <span class="badge bg-secondary text-white">Occupied</span>
                                        </c:when>
                                        <c:when test="${fn:toLowerCase(room.status) == 'maintenance'}">
                                            <span class="badge bg-warning text-dark">Maintenance</span>
                                        </c:when>
                                        <c:when test="${fn:toLowerCase(room.status) == 'dirty'}">
                                            <span class="badge bg-danger text-white">Dirty</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-dark text-white">Unknown</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="${pageContext.request.contextPath}/admin/rooms2?action=view&id=${room.id}" class="btn btn-sm btn-info text-white">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/rooms2?action=form&id=${room.id}" class="btn btn-sm btn-warning text-white">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <!-- "Delete" = set status to maintenance -->
                                        <button onclick="confirmStatusChange(${room.id}, '${room.status}', '${room.roomNumber}')"
                                                class="btn btn-danger text-white">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav class="mt-4">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}">Previous</a>
                </li>
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}">${i}</a>
                    </li>
                </c:forEach>
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}">Next</a>
                </li>
            </ul>
        </nav>
        <div class="text-center text-muted">
            <small>
                Showing ${(currentPage - 1) * recordsPerPage + 1}
                -
                ${currentPage * recordsPerPage > totalRecords ? totalRecords : currentPage * recordsPerPage}
                of ${totalRecords} rooms
            </small>
        </div>
    </c:if>
</div>

<!-- Modal -->
<div class="modal fade" id="statusModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Room Deactivation</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to set room "<span id="roomName"></span>" to <strong>maintenance</strong> mode?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/rooms2" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="roomIdToDelete">
                    <input type="hidden" name="status" value="maintenance">
                    <button type="submit" class="btn btn-primary">Confirm</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function confirmStatusChange(roomId, currentStatus, roomNumber) {
        document.getElementById('roomIdToDelete').value = roomId;
        document.getElementById('roomName').textContent = roomNumber;
        $('#statusModal').modal('show');
    }
</script>

