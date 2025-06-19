<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Services Management</h2>
            <p class="text-muted">Add and manage additional services for guests</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-success" data-toggle="modal" data-target="#addServiceModal">
                <i class="fas fa-plus"></i> Add Service
            </button>
            <button class="btn btn-info" onclick="refreshServiceList()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </div>
    </div>
    
    <!-- Quick Service Add -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Quick Add Service to Guest</h5>
        <form id="quickServiceForm">
            <div class="row">
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Room Number <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="roomNumber" 
                               placeholder="e.g., 101" required>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Service Category</label>
                        <select class="form-control" id="categorySelect" onchange="loadServicesByCategory()">
                            <option value="">All Categories</option>
                            <option value="SPA">Spa & Wellness</option>
                            <option value="TRANSPORT">Transportation</option>
                            <option value="LAUNDRY">Laundry</option>
                            <option value="DINING">Dining</option>
                            <option value="ROOM_SERVICE">Room Service</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Service <span class="text-danger">*</span></label>
                        <select class="form-control" id="serviceSelect" required>
                            <option value="">Select service</option>
                            <c:forEach var="service" items="${services}">
                                <option value="${service.id}" data-price="${service.price}" data-category="${service.category}">
                                    ${service.name} - <fmt:formatNumber value="${service.price}" pattern="#,##0"/>₫
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Quantity <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="quantity" 
                               value="1" min="1" required>
                    </div>
                </div>
                <div class="col-md-1">
                    <div class="form-group">
                        <label>&nbsp;</label>
                        <button type="submit" class="btn btn-primary btn-block">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="alert alert-info">
                        <strong>Total Amount:</strong> <span id="totalAmount">0₫</span>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Service Categories -->
    <div class="row">
        <div class="col-md-4">
            <div class="table-container">
                <div class="text-center mb-3">
                    <div style="width: 60px; height: 60px; background: rgba(46, 213, 115, 0.1); color: #2ed573; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 15px;">
                        <i class="fas fa-spa"></i>
                    </div>
                    <h5>Spa & Wellness</h5>
                    <p class="text-muted mb-3">Relaxation and beauty treatments</p>
                </div>
                <div class="spa-services">
                    <c:forEach var="service" items="${services}">
                        <c:if test="${service.category == 'SPA'}">
                            <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                                <div>
                                    <strong>${service.name}</strong>
                                    <small class="d-block text-muted">${service.description}</small>
                                </div>
                                <span class="text-primary font-weight-bold">
                                    <fmt:formatNumber value="${service.price}" pattern="#,##0"/>₫
                                </span>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
                <button class="btn btn-sm btn-outline-primary btn-block mt-3" 
                        onclick="showServiceCategory('SPA')">
                    View All Spa Services
                </button>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="table-container">
                <div class="text-center mb-3">
                    <div style="width: 60px; height: 60px; background: rgba(0, 123, 255, 0.1); color: #007bff; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 15px;">
                        <i class="fas fa-shuttle-van"></i>
                    </div>
                    <h5>Transportation</h5>
                    <p class="text-muted mb-3">Airport transfers and car services</p>
                </div>
                <div class="transport-services">
                    <c:forEach var="service" items="${services}">
                        <c:if test="${service.category == 'TRANSPORT'}">
                            <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                                <div>
                                    <strong>${service.name}</strong>
                                    <small class="d-block text-muted">${service.description}</small>
                                </div>
                                <span class="text-primary font-weight-bold">
                                    <fmt:formatNumber value="${service.price}" pattern="#,##0"/>₫
                                </span>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
                <button class="btn btn-sm btn-outline-primary btn-block mt-3" 
                        onclick="showServiceCategory('TRANSPORT')">
                    View All Transport Services
                </button>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="table-container">
                <div class="text-center mb-3">
                    <div style="width: 60px; height: 60px; background: rgba(255, 193, 7, 0.1); color: #ffc107; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 15px;">
                        <i class="fas fa-tshirt"></i>
                    </div>
                    <h5>Laundry & Dry Cleaning</h5>
                    <p class="text-muted mb-3">Professional cleaning services</p>
                </div>
                <div class="laundry-services">
                    <c:forEach var="service" items="${services}">
                        <c:if test="${service.category == 'LAUNDRY'}">
                            <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                                <div>
                                    <strong>${service.name}</strong>
                                    <small class="d-block text-muted">${service.description}</small>
                                </div>
                                <span class="text-primary font-weight-bold">
                                    <fmt:formatNumber value="${service.price}" pattern="#,##0"/>₫
                                </span>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
                <button class="btn btn-sm btn-outline-primary btn-block mt-3" 
                        onclick="showServiceCategory('LAUNDRY')">
                    View All Laundry Services
                </button>
            </div>
        </div>
    </div>
    
    <!-- Recent Service Orders -->
    <div class="table-container mt-4">
        <h5 class="mb-3">
            Recent Service Orders
            <button class="btn btn-sm btn-success float-right" onclick="refreshServiceList()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </h5>
        
        <div class="table-responsive">
            <table class="table table-hover" id="serviceOrdersTable">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Room</th>
                        <th>Guest</th>
                        <th>Service</th>
                        <th>Category</th>
                        <th>Quantity</th>
                        <th>Amount</th>
                        <th>Time</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty recentOrders}">
                            <c:forEach var="order" items="${recentOrders}">
                                <tr>
                                    <td>#${order.id}</td>
                                    <td>${order.roomNumber}</td>
                                    <td>${order.guestName}</td>
                                    <td>${order.serviceName}</td>
                                    <td>
                                        <span class="badge badge-info">${order.category}</span>
                                    </td>
                                    <td>${order.quantity}</td>
                                    <td><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0"/>₫</td>
                                    <td><fmt:formatDate value="${order.createdAt}" pattern="HH:mm dd/MM"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.status eq 'PENDING'}">
                                                <span class="badge badge-warning">Pending</span>
                                            </c:when>
                                            <c:when test="${order.status eq 'COMPLETED'}">
                                                <span class="badge badge-success">Completed</span>
                                            </c:when>
                                            <c:when test="${order.status eq 'CANCELLED'}">
                                                <span class="badge badge-danger">Cancelled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">${order.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${order.status eq 'PENDING'}">
                                            <button class="btn btn-sm btn-success" onclick="completeService(${order.id})" title="Complete">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button class="btn btn-sm btn-danger" onclick="cancelService(${order.id})" title="Cancel">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </c:if>
                                        <button class="btn btn-sm btn-info" onclick="viewServiceDetails(${order.id})" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="10" class="text-center text-muted">No service orders found</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Service Modal -->
<div class="modal fade" id="addServiceModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add Service to Room</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="addServiceForm">
                <div class="modal-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        Adding service to Room <strong id="modalRoomNumber"></strong>
                        <br><small>Guest: <span id="modalGuestName"></span></small>
                    </div>
                    
                    <input type="hidden" id="modalReservationId">
                    
                    <div class="form-group">
                        <label>Service Category</label>
                        <select class="form-control" id="modalCategorySelect" onchange="loadModalServices()">
                            <option value="">All Categories</option>
                            <option value="SPA">Spa & Wellness</option>
                            <option value="TRANSPORT">Transportation</option>
                            <option value="LAUNDRY">Laundry</option>
                            <option value="DINING">Dining</option>
                            <option value="ROOM_SERVICE">Room Service</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Service <span class="text-danger">*</span></label>
                        <select class="form-control" id="modalServiceSelect" required>
                            <option value="">Select a service</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Unit Price</label>
                        <input type="text" class="form-control" id="modalServicePrice" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Quantity <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="modalQuantity" 
                               value="1" min="1" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Total Amount</label>
                        <input type="text" class="form-control" id="modalTotalAmount" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea class="form-control" id="modalNotes" rows="2" 
                                  placeholder="Any special instructions..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Service</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Service Category Modal -->
<div class="modal fade" id="serviceCategoryModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalTitle">Service Category</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="categoryServices">
                <!-- Services will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Service select change
    $('#serviceSelect, #quantity').on('change input', function() {
        calculateTotal();
    });
    
    // Modal quantity change
    $('#modalQuantity').on('input', function() {
        calculateModalTotal();
    });
    
    // Modal service change
    $('#modalServiceSelect').on('change', function() {
        updateModalServicePrice();
        calculateModalTotal();
    });
    
    // Quick service form submit
    $('#quickServiceForm').submit(function(e) {
        e.preventDefault();
        quickAddService();
    });
    
    // Add service form submit
    $('#addServiceForm').submit(function(e) {
        e.preventDefault();
        addServiceToReservation();
    });
});

function calculateTotal() {
    const service = $('#serviceSelect option:selected');
    const price = parseFloat(service.data('price')) || 0;
    const quantity = parseInt($('#quantity').val()) || 0;
    const total = price * quantity;
    
    $('#totalAmount').text(formatCurrency(total));
}

function calculateModalTotal() {
    const price = parseFloat($('#modalServicePrice').val().replace(/[^0-9]/g, '')) || 0;
    const quantity = parseInt($('#modalQuantity').val()) || 0;
    const total = price * quantity;
    
    $('#modalTotalAmount').val(formatCurrency(total));
}

function updateModalServicePrice() {
    const service = $('#modalServiceSelect option:selected');
    const price = parseFloat(service.data('price')) || 0;
    $('#modalServicePrice').val(formatCurrency(price));
}

function loadServicesByCategory() {
    const category = $('#categorySelect').val();
    $('#serviceSelect option').each(function() {
        if (!category || $(this).data('category') === category || $(this).val() === '') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
    $('#serviceSelect').val('');
    calculateTotal();
}

function loadModalServices() {
    const category = $('#modalCategorySelect').val();
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/services',
        type: 'POST',
        data: {
            action: 'servicesByCategory',
            category: category
        },
        success: function(services) {
            let html = '<option value="">Select a service</option>';
            services.forEach(function(service) {
                html += '<option value="' + service.id + '" data-price="' + service.price + '">' 
                      + service.name + ' - ' + formatCurrency(service.price) + '</option>';
            });
            $('#modalServiceSelect').html(html);
        }
    });
}

function quickAddService() {
    const roomNumber = $('#roomNumber').val();
    
    if (!roomNumber) {
        alert('Please enter room number');
        return;
    }
    
    // First, find the reservation by room number
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/services',
        type: 'POST',
        data: {
            action: 'findReservationByRoom',
            roomNumber: roomNumber
        },
        success: function(reservation) {
            if (reservation && reservation.id) {
                // Set modal data
                $('#modalReservationId').val(reservation.id);
                $('#modalRoomNumber').text(roomNumber);
                $('#modalGuestName').text(reservation.guestName);
                
                // Pre-select service if chosen
                const serviceId = $('#serviceSelect').val();
                if (serviceId) {
                    $('#modalServiceSelect').val(serviceId);
                    updateModalServicePrice();
                    $('#modalQuantity').val($('#quantity').val());
                    calculateModalTotal();
                }
                
                // Show modal
                $('#addServiceModal').modal('show');
            } else {
                alert('No active reservation found for room ' + roomNumber);
            }
        },
        error: function() {
            alert('Error finding room reservation. Please check the room number.');
        }
    });
}

function addServiceToReservation() {
    const serviceData = {
        reservationId: $('#modalReservationId').val(),
        serviceId: $('#modalServiceSelect').val(),
        quantity: $('#modalQuantity').val(),
        notes: $('#modalNotes').val()
    };
    
    if (!serviceData.serviceId) {
        alert('Please select a service');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/services',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'addService',
            ...serviceData
        }),
        success: function(response) {
            if (response.success) {
                alert('Service added successfully!');
                $('#addServiceModal').modal('hide');
                
                // Reset forms
                $('#quickServiceForm')[0].reset();
                $('#addServiceForm')[0].reset();
                $('#totalAmount').text('0₫');
                
                // Refresh orders list
                refreshServiceList();
            } else {
                alert('Error adding service. Please try again.');
            }
        },
        error: function() {
            alert('Error adding service. Please try again.');
        }
    });
}

function showServiceCategory(category) {
    let title = '';
    switch(category) {
        case 'SPA': title = 'Spa & Wellness Services'; break;
        case 'TRANSPORT': title = 'Transportation Services'; break;
        case 'LAUNDRY': title = 'Laundry & Dry Cleaning Services'; break;
        case 'DINING': title = 'Dining Services'; break;
        case 'ROOM_SERVICE': title = 'Room Service'; break;
        default: title = 'Hotel Services';
    }
    $('#categoryModalTitle').text(title);

    // Load services by category
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/services',
        type: 'POST',
        data: {
            action: 'servicesByCategory',
            category: category
        },
        success: function(services) {
            let html = '<div class="row">';
            services.forEach(function(service) {
                html += 
                    '<div class="col-md-6 mb-3">' +
                        '<div class="card h-100">' +
                            '<div class="card-body">' +
                                '<h6 class="card-title">' + service.name + '</h6>' +
                                '<p class="card-text text-muted">' + (service.description || '') + '</p>' +
                                '<div class="d-flex justify-content-between align-items-center">' +
                                    '<span class="text-primary font-weight-bold">' + formatCurrency(service.price) + '</span>' +
                                    '<button class="btn btn-sm btn-primary" onclick="selectService(' + service.id + ', \'' + service.name.replace(/'/g, "\\'") + '\', ' + service.price + ')">' +
                                        '<i class="fas fa-plus"></i> Add' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
            });
            html += '</div>';
            $('#categoryServices').html(html);
            $('#serviceCategoryModal').modal('show');
        }
    });
}

function selectService(serviceId, serviceName, price) {
    // Close category modal
    $('#serviceCategoryModal').modal('hide');
    
    // Set service in quick form
    $('#serviceSelect').val(serviceId);
    $('#quantity').val(1);
    calculateTotal();
    
    // Focus on room number
    $('#roomNumber').focus();
}

function completeService(orderId) {
    if (confirm('Mark this service as completed?')) {
        updateServiceStatus(orderId, 'COMPLETED');
    }
}

function cancelService(orderId) {
    if (confirm('Cancel this service order?')) {
        updateServiceStatus(orderId, 'CANCELLED');
    }
}

function updateServiceStatus(orderId, status) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/services',
        type: 'POST',
        data: {
            action: 'updateServiceStatus',
            orderId: orderId,
            status: status
        },
        success: function(response) {
            if (response.success) {
                alert('Service status updated successfully!');
                refreshServiceList();
            } else {
                alert('Error updating service status.');
            }
        },
        error: function() {
            alert('Error updating service status.');
        }
    });
}

function viewServiceDetails(orderId) {
    // Implement service details view
    alert('Service details view - Order ID: ' + orderId);
}

function refreshServiceList() {
    location.reload();
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + '₫';
}
</script>