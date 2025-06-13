<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Room Types Management</li>
        </ol>
    </nav>
    
  
    
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
    
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Filters and Search -->
<div class="card mb-4">
    <div class="card-body" style="padding: 0.75rem;">
        <form method="get" action="${pageContext.request.contextPath}/admin/rooms" class="form-inline d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center">
                <!-- Search -->
                <div class="form-group mr-2 mb-0">
                    <label class="mr-1" style="font-size: 0.875rem;">Search:</label>
                    <input type="text" name="keyword" class="form-control form-control-sm" 
                           placeholder="Room type name..." value="${keyword}" style="width: 140px;">
                </div>
                
                <!-- Price Filter -->
                <div class="form-group mr-2 mb-0">
                    <label class="mr-1" style="font-size: 0.875rem;">Price:</label>
                    <select name="price" class="form-control form-control-sm" style="width: 110px;">
                        <option value="">All Prices</option>
                        <option value="1" ${selectedPrice == '1' ? 'selected' : ''}>Under 500k</option>
                        <option value="2" ${selectedPrice == '2' ? 'selected' : ''}>500k - 1M</option>
                        <option value="3" ${selectedPrice == '3' ? 'selected' : ''}>Over 1M</option>
                    </select>
                </div>
                
                <!-- Capacity Filter -->
                <div class="form-group mr-2 mb-0">
                    <label class="mr-1" style="font-size: 0.875rem;">Capacity:</label>
                    <select name="capacity" class="form-control form-control-sm" style="width: 110px;">
                        <option value="">All Capacities</option>
                        <option value="1" ${selectedCapacity == '1' ? 'selected' : ''}>1 Person</option>
                        <option value="2" ${selectedCapacity == '2' ? 'selected' : ''}>2 People</option>
                        <option value="3" ${selectedCapacity == '3' ? 'selected' : ''}>3+ People</option>
                    </select>
                </div>
                
                <!-- Status Filter -->
                <div class="form-group mr-2 mb-0">
                    <label class="mr-1" style="font-size: 0.875rem;">Status:</label>
                    <select name="status" class="form-control form-control-sm" style="width: 110px;">
                        <option value="">All Status</option>
                        <option value="active" ${selectedStatus == 'active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${selectedStatus == 'inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary btn-sm">
                    <i class="fas fa-filter"></i> Filter
                </button>
                    
                <c:if test="${not empty keyword || not empty selectedPrice || not empty selectedCapacity || not empty selectedStatus}">
                    <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-secondary btn-sm ml-2">
                        <i class="fas fa-times"></i> Clear
                    </a>
                </c:if>
            </div>
            
            <a href="${pageContext.request.contextPath}/admin/rooms?action=form" class="btn btn-success btn-sm">
                <i class="fas fa-plus"></i> Add New Room Type
            </a>
        </form>
    </div>
</div>
    
    <!-- Room Types Cards -->
    <div class="row">
        <c:choose>
            <c:when test="${not empty roomTypes}">
                <c:forEach var="roomType" items="${roomTypes}" varStatus="status">
                    <c:set var="startIndex" value="${(currentPage - 1) * recordsPerPage}" />
                    <c:set var="endIndex" value="${startIndex + recordsPerPage}" />
                    <c:if test="${status.index >= startIndex && status.index < endIndex}">
                        <div class="col-lg-6 col-xl-4 mb-4">
                            <div class="card h-100">
                                <div class="card-img-wrapper" style="height: 200px; overflow: hidden;">
                                    <img src="${pageContext.request.contextPath}/assets/images/uploads/${roomType.imageUrl}" 
                                         class="card-img-top" alt="Room Type Image" 
                                         style="height: 100%; width: 100%; object-fit: cover;">
                                </div>
                                <div class="card-body d-flex flex-column">
                                    <h5 class="card-title">${roomType.name}</h5>
                                    <div class="mb-2">
                                        <span class="badge badge-${roomType.status == 'active' ? 'success' : 'danger'}">
                                            ${roomType.status == 'active' ? 'Active' : 'Inactive'}
                                        </span>
                                    </div>
                                    
                                    <div class="row mb-2">
                                        <div class="col-6">
                                            <small class="text-muted">Capacity:</small>
                                            <br><strong>${roomType.capacity} guests</strong>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted">Price:</small>
                                            <br><strong>
                                                <fmt:formatNumber value="${roomType.basePrice}" pattern="#,##0" />₫/night
                                            </strong>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <small class="text-muted">Description:</small>
                                        <p class="card-text">
                                            <c:choose>
                                                <c:when test="${roomType.description.length() > 100}">
                                                    ${roomType.description.substring(0, 100)}...
                                                </c:when>
                                                <c:otherwise>
                                                    ${roomType.description}
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    
                                    <div class="mt-auto">
                                        <div class="btn-group w-100" role="group">
                                            <a href="${pageContext.request.contextPath}/admin/rooms?action=view&id=${roomType.id}" 
                                               class="btn btn-info btn-sm">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/rooms?action=form&id=${roomType.id}" 
                                               class="btn btn-warning btn-sm">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                            <button onclick="confirmStatusChange(${roomType.id}, '${roomType.status}', '${roomType.name}')" 
                                                    class="btn btn-${roomType.status == 'active' ? 'danger' : 'success'} btn-sm">
                                                <i class="fas fa-${roomType.status == 'active' ? 'ban' : 'check'}"></i> 
                                                ${roomType.status == 'active' ? 'Deactivate' : 'Activate'}
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-footer text-muted">
                                    <small>
                                        Created: <fmt:formatDate value="${roomType.createdAt}" pattern="dd/MM/yyyy"/>
                                        <c:if test="${roomType.updatedAt != null}">
                                            | Updated: <fmt:formatDate value="${roomType.updatedAt}" pattern="dd/MM/yyyy"/>
                                        </c:if>
                                    </small>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="fas fa-bed fa-3x text-muted mb-3"></i>
                        <p class="text-muted">No room types found</p>
                        <a href="${pageContext.request.contextPath}/admin/rooms?action=form" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add First Room Type
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&status=${selectedStatus}">
                        Previous
                    </a>
                </li>
                
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&status=${selectedStatus}">
                                ${i}
                            </a>
                        </li>
                    </c:if>
                    <c:if test="${i == currentPage - 3 || i == currentPage + 3}">
                        <li class="page-item disabled">
                            <span class="page-link">...</span>
                        </li>
                    </c:if>
                </c:forEach>
                
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&status=${selectedStatus}">
                        Next
                    </a>
                </li>
            </ul>
        </nav>
        
        <div class="text-center text-muted">
            <small>
                Showing ${(currentPage - 1) * recordsPerPage + 1} - 
                ${currentPage * recordsPerPage > totalRecords ? totalRecords : currentPage * recordsPerPage} 
                of ${totalRecords} room types
            </small>
        </div>
    </c:if>
</div>

<!-- Status Change Confirmation Modal -->
<div class="modal fade" id="statusModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Status Change</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to <span id="statusAction"></span> room type "<span id="roomTypeName"></span>"?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/rooms" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="statusRoomTypeId">
                    <input type="hidden" name="status" id="statusValue">
                    <button type="submit" class="btn btn-primary">Confirm</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function confirmStatusChange(roomTypeId, currentStatus, roomTypeName) {
    var newStatus = currentStatus === 'active' ? 'inactive' : 'active';
    var action = newStatus === 'active' ? 'activate' : 'deactivate';
    
    document.getElementById('statusAction').textContent = action;
    document.getElementById('roomTypeName').textContent = roomTypeName;
    document.getElementById('statusRoomTypeId').value = roomTypeId;
    document.getElementById('statusValue').value = newStatus;
    
    $('#statusModal').modal('show');
}
</script>