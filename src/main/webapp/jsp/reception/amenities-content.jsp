<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.room-card {
    background: white;
    border-radius: 8px;
    padding: 15px;
    text-align: center;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    cursor: pointer;
    transition: all 0.3s;
    border: 2px solid transparent;
    margin-bottom: 10px;
}

.room-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
}

.room-card.selected {
    border-color: #17a2b8;
    background: rgba(23, 162, 184, 0.1);
}

.room-card.occupied {
    background: #fff5f5;
    border-color: #f8d7da;
}

.room-number {
    font-size: 20px;
    font-weight: bold;
    color: #17a2b8;
    margin-bottom: 8px;
}

.room-status {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 15px;
    font-size: 11px;
    font-weight: 500;
}

.status-available { background: #d4edda; color: #155724; }
.status-occupied { background: #f8d7da; color: #721c24; }
.status-maintenance { background: #fff3cd; color: #856404; }
.status-dirty { background: #e2e3e5; color: #383d41; }

.amenity-item {
    border: 1px solid #dee2e6;
    border-radius: 6px;
    padding: 12px;
    margin-bottom: 10px;
    background: white;
}

.amenity-item.chargeable {
    background: #fff8e1;
    border-color: #ffecb3;
}

.amenity-controls {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: 8px;
}

.quantity-control {
    display: flex;
    align-items: center;
    gap: 8px;
}

.quantity-control button {
    width: 28px;
    height: 28px;
    padding: 0;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.quantity-display {
    min-width: 30px;
    text-align: center;
    font-weight: bold;
}
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2>Room Amenities Management</h2>
            <p class="text-muted">Track and manage minibar and room amenities usage</p>
        </div>
    </div>
    
    <!-- Floor Selection -->
    <div class="table-container mb-4">
        <div class="d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
                <h5 class="mb-0 mr-4">Select Floor:</h5>
                <div class="btn-group" role="group">
                    <button class="btn btn-outline-primary active" data-floor="1" onclick="selectFloor(1)">Floor 1</button>
                    <button class="btn btn-outline-primary" data-floor="2" onclick="selectFloor(2)">Floor 2</button>
                    <button class="btn btn-outline-primary" data-floor="3" onclick="selectFloor(3)">Floor 3</button>
                    <button class="btn btn-outline-primary" data-floor="5" onclick="selectFloor(5)">Floor 5</button>
                    <button class="btn btn-outline-primary" data-floor="6" onclick="selectFloor(6)">Floor 6</button>
                </div>
            </div>
            <div>
                <button class="btn btn-success" onclick="saveAllChanges()">
                    <i class="fas fa-save"></i> Save All Changes
                </button>
                <button class="btn btn-info" onclick="refreshAmenities()">
                    <i class="fas fa-sync"></i> Refresh
                </button>
            </div>
        </div>
    </div>
    
    <!-- Room Grid and Amenity Management -->
    <div class="row">
        <div class="col-md-4">
            <div class="table-container">
                <h5 class="mb-3">Select Room</h5>
                <div id="roomGrid">
                    <!-- Rooms will be loaded here based on floor -->
                </div>
            </div>
        </div>
        
        <div class="col-md-8">
            <div id="amenityManagement" style="display: none;">
                <div class="table-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0">
                            Room <span id="selectedRoomNumber"></span> - Amenities Usage
                        </h5>
                        <button class="btn btn-success" onclick="saveAmenityUsage()">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <div class="bg-light p-3 rounded">
                                <strong>Guest:</strong> <span id="guestName">-</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="bg-light p-3 rounded">
                                <strong>Check-in:</strong> <span id="checkInDate">-</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="bg-light p-3 rounded">
                                <strong>Days Stayed:</strong> <span id="daysStayed">-</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6 class="mb-3">
                                <i class="fas fa-wine-bottle"></i> Minibar Items
                            </h6>
                            <div id="minibarItems">
                                <!-- Minibar items will be loaded here -->
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <h6 class="mb-3">
                                <i class="fas fa-tv"></i> Room Amenities
                            </h6>
                            <div id="roomAmenities">
                                <!-- Room amenities will be loaded here -->
                            </div>
                        </div>
                    </div>
                    
                    <div class="mt-4 p-3 bg-warning text-dark rounded">
                        <h6><i class="fas fa-calculator"></i> Usage Summary</h6>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="d-flex justify-content-between">
                                    <span>Minibar Charges:</span>
                                    <strong id="minibarTotal">0₫</strong>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex justify-content-between">
                                    <span>Amenity Charges:</span>
                                    <strong id="amenityTotal">0₫</strong>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex justify-content-between">
                                    <h6>Total Charges:</h6>
                                    <h6 id="totalCharges">0₫</h6>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="noRoomSelected" class="table-container text-center py-5">
                <i class="fas fa-door-open fa-3x text-muted mb-3"></i>
                <p class="text-muted">Please select a room to manage amenities</p>
            </div>
        </div>
    </div>
    
    <!-- Recent Activity Log -->
    <div class="table-container mt-4">
        <h5 class="mb-3">Recent Amenity Usage Log</h5>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Room</th>
                        <th>Guest</th>
                        <th>Amenity</th>
                        <th>Quantity</th>
                        <th>Amount</th>
                        <th>Staff</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty recentLogs}">
                            <c:forEach var="log" items="${recentLogs}">
                                <tr>
                                    <td><fmt:formatDate value="${log.checkedAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                                    <td><strong>Room ${log.roomNumber}</strong></td>
                                    <td>${log.guestName}</td>
                                    <td>
                                        ${log.amenityName}
                                        <c:if test="${log.isChargeable}">
                                            <span class="badge badge-warning">Chargeable</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <span class="badge badge-primary">${log.quantity}x</span>
                                    </td>
                                    <td>
                                        <strong class="text-primary">
                                            <fmt:formatNumber value="${log.totalPrice}" pattern="#,##0"/>₫
                                        </strong>
                                    </td>
                                    <td>${log.checkedByName}</td>
                                    <td>
                                        <button class="btn btn-sm btn-info" onclick="viewAmenityDetails(${log.id})" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <c:if test="${log.checkedBy == currentUser.id}">
                                            <button class="btn btn-sm btn-warning" onclick="editAmenityLog(${log.id})" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8" class="text-center text-muted">No amenity usage logs found</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Amenity Modal -->
<div class="modal fade" id="addAmenityModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add New Amenity</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="addAmenityForm">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Amenity Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="amenityName" required 
                               placeholder="Enter amenity name">
                    </div>
                    
                    <div class="form-group">
                        <label>Category</label>
                        <select class="form-control" id="amenityCategory">
                            <option value="MINIBAR">Minibar</option>
                            <option value="AMENITY">Room Amenity</option>
                            <option value="ELECTRONICS">Electronics</option>
                            <option value="BATHROOM">Bathroom</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Description</label>
                        <textarea class="form-control" id="amenityDescription" rows="2"
                                  placeholder="Enter description"></textarea>
                    </div>
                    
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input" id="isChargeable">
                        <label class="form-check-label" for="isChargeable">
                            This is a chargeable item
                        </label>
                    </div>
                    
                    <div class="form-group" id="priceGroup" style="display: none;">
                        <label>Unit Price (₫) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="amenityPrice" min="0" step="1000"
                               placeholder="Enter unit price">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Amenity</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentFloor = 1;
let currentRoom = null;
let currentReservation = null;
let amenityUsage = {};
let allAmenities = [];

$(document).ready(function() {
    loadRoomsByFloor(1);
    
    $('#isChargeable').change(function() {
        if ($(this).is(':checked')) {
            $('#priceGroup').show();
            $('#amenityPrice').attr('required', true);
        } else {
            $('#priceGroup').hide();
            $('#amenityPrice').attr('required', false);
        }
    });
    
    $('#addAmenityForm').submit(function(e) {
        e.preventDefault();
        addNewAmenity();
    });
});

function selectFloor(floor) {
    currentFloor = floor;
    $('.btn-group .btn').removeClass('active');
    $('[data-floor="' + floor + '"]').addClass('active');
    loadRoomsByFloor(floor);

    // Reset selection
    currentRoom = null;
    $('#amenityManagement').hide();
    $('#noRoomSelected').show();
}

function loadRoomsByFloor(floor) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/amenities',
        type: 'POST',
        data: {
            action: 'getRoomsByFloor',
            floor: floor
        },
        success: function(rooms) {
            let html = '';
            rooms.forEach(function(room) {
                let statusClass = '';
                let statusBadge = '';
                let statusText = '';
                
                switch(room.status) {
                    case 'OCCUPIED':
                        statusClass = 'occupied';
                        statusBadge = 'status-occupied';
                        statusText = 'Occupied';
                        break;
                    case 'AVAILABLE':
                        statusBadge = 'status-available';
                        statusText = 'Available';
                        break;
                    case 'MAINTENANCE':
                        statusBadge = 'status-maintenance';
                        statusText = 'Maintenance';
                        break;
                    case 'DIRTY':
                        statusBadge = 'status-dirty';
                        statusText = 'Dirty';
                        break;
                    default:
                        statusBadge = 'status-available';
                        statusText = 'Available';
                }

                html += '<div class="room-card ' + statusClass + '" '
                      +     'data-room-id="' + room.id + '" '
                      +     'data-room-number="' + room.roomNumber + '" '
                      +     'data-status="' + room.status + '" '
                      +     'onclick="selectRoom(' + room.id + ', \'' + room.roomNumber + '\', \'' + room.status + '\')">';
                html +=   '<div class="room-number">' + room.roomNumber + '</div>';
                html +=   '<span class="room-status ' + statusBadge + '">' + statusText + '</span>';
                html += '</div>';
            });
            $('#roomGrid').html(html);
        },
        error: function() {
            alert('Error loading rooms');
        }
    });
}

function selectRoom(roomId, roomNumber, status) {
    if (status !== 'OCCUPIED') {
        alert('This room is not currently occupied. Amenity tracking is only available for occupied rooms.');
        return;
    }

    currentRoom = roomId;
    $('.room-card').removeClass('selected');
    $('.room-card[data-room-id="' + roomId + '"]').addClass('selected');

    $('#selectedRoomNumber').text(roomNumber);
    $('#noRoomSelected').hide();
    $('#amenityManagement').show();

    loadRoomAmenities(roomId);
}

function loadRoomAmenities(roomId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/amenities',
        type: 'POST',
        data: {
            action: 'getRoomAmenityStatus',
            roomId: roomId
        },
        success: function(data) {
            if (data.reservation) {
                currentReservation = data.reservation;
                
                $('#guestName').text(data.reservation.guestName);
                $('#checkInDate').text(formatDate(data.reservation.checkIn));
                $('#daysStayed').text(data.reservation.daysStayed);

                amenityUsage = {};
                allAmenities = [...(data.minibarItems || []), ...(data.roomAmenities || [])];

                // Load minibar items
                let minibarHtml = '';
                if (data.minibarItems) {
                    data.minibarItems.forEach(function(item) {
                        const usage = data.currentUsage[item.id] || 0;
                        amenityUsage[item.id] = usage;
                        minibarHtml += createAmenityItem(item, usage);
                    });
                }
                $('#minibarItems').html(minibarHtml || '<p class="text-muted">No minibar items</p>');

                // Load room amenities
                let amenityHtml = '';
                if (data.roomAmenities) {
                    data.roomAmenities.forEach(function(item) {
                        const usage = data.currentUsage[item.id] || 0;
                        amenityUsage[item.id] = usage;
                        amenityHtml += createAmenityItem(item, usage);
                    });
                }
                $('#roomAmenities').html(amenityHtml || '<p class="text-muted">No room amenities</p>');

                updateTotals();
            } else {
                alert('No reservation data found for this room');
            }
        },
        error: function() {
            alert('Error loading room amenities');
        }
    });
}

function createAmenityItem(item, usage) {
    const itemClass = item.isChargeable ? 'chargeable' : '';
    let html = '<div class="amenity-item ' + itemClass + '">';
    html    +=   '<div class="d-flex justify-content-between align-items-start">';
    html    +=     '<div>';
    html    +=       '<strong>' + item.name + '</strong>';
    if (item.description) {
        html +=       '<small class="d-block text-muted">' + item.description + '</small>';
    }
    if (item.isChargeable) {
        html +=       '<small class="text-primary">' + formatCurrency(item.unitPrice) + ' each</small>';
    }
    html    +=     '</div>';
    
    if (item.isChargeable) {
        html +=     '<div class="text-right">';
        html +=       '<div class="font-weight-bold" id="total_' + item.id + '">';
        html +=         formatCurrency(usage * item.unitPrice);
        html +=       '</div>';
        html +=     '</div>';
    }
    html    +=   '</div>';
    
    html    +=   '<div class="amenity-controls">';
    if (item.isChargeable) {
        html +=     '<div class="quantity-control">';
        html +=       '<button class="btn btn-sm btn-outline-danger" onclick="updateQuantity(' + item.id + ', -1, ' + item.unitPrice + ')">';
        html +=         '<i class="fas fa-minus"></i>';
        html +=       '</button>';
        html +=       '<span class="quantity-display" id="quantity_' + item.id + '">' + usage + '</span>';
        html +=       '<button class="btn btn-sm btn-outline-success" onclick="updateQuantity(' + item.id + ', 1, ' + item.unitPrice + ')">';
        html +=         '<i class="fas fa-plus"></i>';
        html +=       '</button>';
        html +=     '</div>';
    } else {
        html +=     '<div class="form-check">';
        html +=       '<input type="checkbox" class="form-check-input" id="check_' + item.id + '"';
        html +=              (usage > 0 ? ' checked' : '') + ' onchange="toggleAmenity(' + item.id + ')">';
        html +=       '<label class="form-check-label" for="check_' + item.id + '">Present</label>';
        html +=     '</div>';
    }
    html    +=   '</div>';
    html    += '</div>';
    
    return html;
}

function updateQuantity(amenityId, change, unitPrice) {
    const currentQty = amenityUsage[amenityId] || 0;
    const newQty = Math.max(0, currentQty + change);
    amenityUsage[amenityId] = newQty;
    
    $('#quantity_' + amenityId).text(newQty);
    $('#total_' + amenityId).text(formatCurrency(newQty * unitPrice));
    updateTotals();
}

function toggleAmenity(amenityId) {
    const isChecked = $('#check_' + amenityId).is(':checked');
    amenityUsage[amenityId] = isChecked ? 1 : 0;
    updateTotals();
}

function updateTotals() {
    let minibarTotal = 0;
    let amenityTotal = 0;
    
    Object.keys(amenityUsage).forEach(function(amenityId) {
        const qty = amenityUsage[amenityId];
        if (qty > 0) {
            const amenity = allAmenities.find(a => a.id == amenityId);
            if (amenity && amenity.isChargeable) {
                const itemTotal = qty * amenity.unitPrice;
                if (amenity.category === 'MINIBAR') {
                    minibarTotal += itemTotal;
                } else {
                    amenityTotal += itemTotal;
                }
            }
        }
    });
    
    $('#minibarTotal').text(formatCurrency(minibarTotal));
    $('#amenityTotal').text(formatCurrency(amenityTotal));
    $('#totalCharges').text(formatCurrency(minibarTotal + amenityTotal));
}

function saveAmenityUsage() {
    if (!currentRoom || !currentReservation) {
        alert('Please select a room first');
        return;
    }
    
    const usageData = {
        reservationId: currentReservation.id,
        roomId: currentRoom,
        amenityUsage: []
    };
    
    Object.keys(amenityUsage).forEach(function(amenityId) {
        const qty = amenityUsage[amenityId];
        if (qty > 0) {
            usageData.amenityUsage.push({
                amenityId: parseInt(amenityId),
                quantity: qty
            });
        }
    });
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/amenities',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'saveAmenityUsage',
            ...usageData
        }),
        success: function(response) {
            if (response.success) {
                alert('Amenity usage saved successfully!');
                // Refresh the current room data
                loadRoomAmenities(currentRoom);
            } else {
                alert('Error saving amenity usage: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error saving amenity usage. Please try again.');
        }
    });
}

function saveAllChanges() {
    if (currentRoom) {
        saveAmenityUsage();
    } else {
        alert('Please select a room first');
    }
}

function refreshAmenities() {
    if (currentRoom) {
        loadRoomAmenities(currentRoom);
    } else {
        loadRoomsByFloor(currentFloor);
    }
}

function addNewAmenity() {
    const amenityData = {
        name: $('#amenityName').val(),
        category: $('#amenityCategory').val(),
        description: $('#amenityDescription').val(),
        isChargeable: $('#isChargeable').is(':checked'),
        unitPrice: $('#isChargeable').is(':checked') ? $('#amenityPrice').val() : 0
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/amenities',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'addAmenity',
            ...amenityData
        }),
        success: function(response) {
            if (response.success) {
                alert('Amenity added successfully!');
                $('#addAmenityModal').modal('hide');
                $('#addAmenityForm')[0].reset();
                $('#priceGroup').hide();
                
                // Refresh current room if selected
                if (currentRoom) {
                    loadRoomAmenities(currentRoom);
                }
            } else {
                alert('Error adding amenity: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error adding amenity. Please try again.');
        }
    });
}

function viewAmenityDetails(logId) {
    // Implement amenity log details view
    alert('Amenity details view - Log ID: ' + logId);
}

function editAmenityLog(logId) {
    // Implement amenity log editing
    alert('Edit amenity log - Log ID: ' + logId);
}

function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '0₫';
    return new Intl.NumberFormat('vi-VN').format(amount) + '₫';
}
</script>