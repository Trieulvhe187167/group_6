<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.item-card {
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 10px;
    transition: all 0.3s;
}

.item-card:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.damage-card {
    border: 1px solid #dc3545;
    background-color: #fff5f5;
}

.severity-badge {
    font-size: 12px;
    padding: 3px 8px;
    border-radius: 12px;
}

.severity-minor { background: #d1ecf1; color: #0c5460; }
.severity-moderate { background: #fff3cd; color: #856404; }
.severity-major { background: #f8d7da; color: #721c24; }
.severity-severe { background: #d1616a; color: white; }
</style>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Edit Inspection</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Room Inspection - ${inspection.reservation.roomNumber}</h1>
        <div>
            <button type="button" class="btn btn-success" onclick="saveProgress()">
                <i class="fas fa-save"></i> Save Progress
            </button>
            <button type="button" class="btn btn-primary" onclick="completeInspection()">
                <i class="fas fa-check-circle"></i> Complete Inspection
            </button>
        </div>
    </div>
    
    <!-- Inspection Summary -->
    <div class="row">
        <div class="col-md-8">
            <!-- Basic Info -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Inspection Details</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Guest:</strong> ${inspection.reservation.customerName}</p>
                            <p><strong>Room Type:</strong> ${inspection.reservation.roomTypeName}</p>
                            <p><strong>Stay Period:</strong> 
                                <fmt:formatDate value="${inspection.reservation.checkIn}" pattern="dd/MM"/> - 
                                <fmt:formatDate value="${inspection.reservation.checkOut}" pattern="dd/MM/yyyy"/>
                            </p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Room Condition:</strong> 
                                <span class="room-condition-badge condition-${inspection.roomCondition.toLowerCase()}">
                                    ${inspection.roomCondition}
                                </span>
                            </p>
                            <p><strong>Cleanliness Score:</strong> ${inspection.cleanlinessScore}/10</p>
                            <p><strong>Status:</strong> 
                                <span class="badge badge-${inspection.status == 'PENDING' ? 'warning' : 'success'}">
                                    ${inspection.status}
                                </span>
                            </p>
                        </div>
                    </div>
                     
                    <div class="form-group mt-3">
                        <label for="inspectionNotes">Inspection Notes:</label>
                        <textarea class="form-control" id="inspectionNotes" rows="3">${inspection.notes}</textarea>
                    </div>
                </div>
            </div>
            
            <!-- Minibar & Amenities Usage -->
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Minibar & Amenities Usage</h5>
                    <button type="button" class="btn btn-sm btn-primary" data-toggle="modal" data-target="#addItemModal">
                        <i class="fas fa-plus"></i> Add Item
                    </button>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty inspection.inspectionItems}">
                            <c:forEach var="item" items="${inspection.inspectionItems}">
                                <div class="item-card">
                                    <div class="row align-items-center">
                                        <div class="col-md-4">
                                            <strong>${item.itemName}</strong>
                                            <br>
                                            <small class="text-muted">${item.itemCategory}</small>
                                        </div>
                                        <div class="col-md-2 text-center">
                                            Qty: ${item.quantity}
                                        </div>
                                        <div class="col-md-2 text-center">
                                            <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/>₫
                                        </div>
                                        <div class="col-md-2 text-center">
                                            <strong><fmt:formatNumber value="${item.totalPrice}" pattern="#,##0"/>₫</strong>
                                        </div>
                                        <div class="col-md-2 text-right">
                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="deleteItem(${item.id})">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <c:if test="${not empty item.notes}">
                                        <small class="text-muted mt-1"><i>${item.notes}</i></small>
                                    </c:if>
                                </div>
                            </c:forEach>
                            
                            <div class="text-right mt-3">
                                <h6>Subtotal: 
                                    <span class="text-primary">
                                        <fmt:formatNumber value="${inspection.totalItemCharges}" pattern="#,##0"/>₫
                                    </span>
                                </h6>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted text-center py-3">No items recorded yet.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <!-- Room Damages -->
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Room Damages</h5>
                    <button type="button" class="btn btn-sm btn-danger" data-toggle="modal" data-target="#addDamageModal">
                        <i class="fas fa-exclamation-triangle"></i> Report Damage
                    </button>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty inspection.roomDamages}">
                            <c:forEach var="damage" items="${inspection.roomDamages}">
                                <div class="item-card damage-card">
                                    <div class="row">
                                        <div class="col-md-8">
                                            <div class="d-flex align-items-center mb-2">
                                                <strong>${damage.damageType}</strong>
                                                <span class="severity-badge severity-${damage.severity.toLowerCase()} ml-2">
                                                    ${damage.severity}
                                                </span>
                                            </div>
                                            <p class="mb-1">${damage.description}</p>
                                            <p class="mb-0">
                                                <strong>Estimated Cost:</strong> 
                                                <span class="text-danger">
                                                    <fmt:formatNumber value="${damage.estimatedCost}" pattern="#,##0"/>₫
                                                </span>
                                            </p>
                                        </div>
                                        <div class="col-md-4 text-right">
                                            <c:if test="${not empty damage.photoUrl}">
                                                <a href="${pageContext.request.contextPath}/uploads/${damage.photoUrl}" 
                                                   target="_blank" class="btn btn-sm btn-info">
                                                    <i class="fas fa-image"></i> View Photo
                                                </a>
                                            </c:if>
                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="deleteDamage(${damage.id})">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <div class="text-right mt-3">
                                <h6>Total Damage Cost: 
                                    <span class="text-danger">
                                        <fmt:formatNumber value="${inspection.totalDamageCharges}" pattern="#,##0"/>₫
                                    </span>
                                </h6>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted text-center py-3">No damages reported.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <!-- Summary Sidebar -->
        <div class="col-md-4">
            <div class="card bg-light">
                <div class="card-header">
                    <h5 class="mb-0">Charges Summary</h5>
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between mb-2">
                        <span>Room Rate:</span>
                        <strong><fmt:formatNumber value="${inspection.reservation.totalAmount}" pattern="#,##0"/>₫</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Minibar/Amenities:</span>
                        <strong><fmt:formatNumber value="${inspection.totalItemCharges}" pattern="#,##0"/>₫</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Damages:</span>
                        <strong class="text-danger">
                            <fmt:formatNumber value="${inspection.totalDamageCharges}" pattern="#,##0"/>₫
                        </strong>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between">
                        <h6>Additional Charges:</h6>
                        <h6 class="text-primary">
                            <fmt:formatNumber value="${inspection.totalCharges}" pattern="#,##0"/>₫
                        </h6>
                    </div>
                </div>
            </div>
            
            <!-- Quick Add Buttons -->
            <div class="card mt-3">
                <div class="card-header">
                    <h6 class="mb-0">Quick Add Items</h6>
                </div>
                <div class="card-body">
                    <button type="button" class="btn btn-sm btn-outline-primary btn-block mb-2"
                            onclick="quickAddItem('Beer - Heineken 330ml', 'MINIBAR', 50000)">
                        <i class="fas fa-beer"></i> Beer (50,000₫)
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-primary btn-block mb-2"
                            onclick="quickAddItem('Soft Drink - Coca Cola', 'MINIBAR', 30000)">
                        <i class="fas fa-glass-whiskey"></i> Soft Drink (30,000₫)
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-primary btn-block mb-2"
                            onclick="quickAddItem('Snacks', 'MINIBAR', 40000)">
                        <i class="fas fa-cookie-bite"></i> Snacks (40,000₫)
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-primary btn-block"
                            onclick="quickAddItem('Water - 500ml', 'MINIBAR', 20000)">
                        <i class="fas fa-tint"></i> Water (20,000₫)
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Item Modal -->
<div class="modal fade" id="addItemModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add Used Item</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="addItemForm">
                <div class="modal-body">
                    <input type="hidden" name="inspectionId" value="${inspection.id}">
                    
                    <div class="form-group">
                        <label>Item Category</label>
                        <select class="form-control" name="itemCategory" required>
                            <option value="MINIBAR">Minibar</option>
                            <option value="AMENITY">Amenity</option>
                            <option value="SERVICE">Room Service</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Item Name</label>
                        <select class="form-control" id="itemSelect" name="itemName" required>
                            <option value="">Select an item...</option>
                            <c:forEach var="amenity" items="${amenities}">
                                <option value="${amenity.name}" data-price="${amenity.unitPrice}">
                                    ${amenity.name} - <fmt:formatNumber value="${amenity.unitPrice}" pattern="#,##0"/>₫
                                </option>
                            </c:forEach>
                            <option value="custom">Other (Custom Item)</option>
                        </select>
                        <input type="text" class="form-control mt-2" id="customItemName" 
                               name="customItemName" placeholder="Enter item name" style="display:none;">
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Quantity</label>
                                <input type="number" class="form-control" name="quantity" 
                                       value="1" min="1" maxlength="3" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Unit Price (₫)</label>
                                <input type="number" class="form-control" name="unitPrice" 
                                       id="unitPrice" min="0" maxlength="9" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Notes (Optional)</label>
                        <textarea class="form-control" name="notes" rows="2" maxlength="200"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Item</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Damage Modal -->
<div class="modal fade" id="addDamageModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Report Room Damage</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="addDamageForm" enctype="multipart/form-data">
                <div class="modal-body">
                    <input type="hidden" name="inspectionId" value="${inspection.id}">
                    
                    <div class="form-group">
                        <label>Damage Type</label>
                        <select class="form-control" name="damageType" required>
                            <option value="">Select type...</option>
                            <option value="FURNITURE">Furniture</option>
                            <option value="ELECTRONICS">Electronics</option>
                            <option value="BATHROOM">Bathroom</option>
                            <option value="WALLS">Walls/Paint</option>
                            <option value="CARPET">Carpet/Floor</option>
                            <option value="LINEN">Linen/Bedding</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Description</label>
                        <textarea class="form-control" name="description" rows="3" required
                                  placeholder="Describe the damage in detail..."></textarea>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Severity</label>
                                <select class="form-control" name="severity" required>
                                    <option value="MINOR">Minor</option>
                                    <option value="MODERATE">Moderate</option>
                                    <option value="MAJOR">Major</option>
                                    <option value="SEVERE">Severe</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Estimated Cost (₫)</label>
                                <input type="number" class="form-control" name="estimatedCost" 
                                       min="0" maxlength="9" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Photo Evidence (Optional)</label>
                        <div class="custom-file">
                            <input type="file" class="custom-file-input" id="damagePhoto" 
                                   name="photo" accept="image/*">
                            <label class="custom-file-label" for="damagePhoto">Choose file</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Report Damage</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Item selection handling
$('#itemSelect').on('change', function() {
    if ($(this).val() === 'custom') {
        $('#customItemName').show().attr('required', true);
        $('#unitPrice').val('').attr('readonly', false);
    } else {
        $('#customItemName').hide().attr('required', false);
        const price = $(this).find(':selected').data('price');
        if (price) {
            $('#unitPrice').val(price).attr('readonly', true);
        }
    }
});

// Add item form submission
$('#addItemForm').on('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    if ($('#itemSelect').val() === 'custom') {
        formData.set('itemName', $('#customItemName').val());
    }
    formData.append('action', 'addItem');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/inspector/inspection',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                showToast('Item added successfully');
                $('#addItemModal').modal('hide');
                setTimeout(() => location.reload(), 1000);
            } else {
                showToast(response.message || 'Error adding item', 'danger');
            }
        },
        error: function() {
            showToast('Error adding item', 'danger');
        }
    });
});

// Add damage form submission
$('#addDamageForm').on('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    formData.append('action', 'addDamage');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/inspector/inspection',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                showToast('Damage reported successfully');
                $('#addDamageModal').modal('hide');
                setTimeout(() => location.reload(), 1000);
            } else {
                showToast(response.message || 'Error reporting damage', 'danger');
            }
        },
        error: function() {
            showToast('Error reporting damage', 'danger');
        }
    });
});

// Quick add item
function quickAddItem(name, category, price) {
    const data = {
        action: 'addItem',
        inspectionId: ${inspection.id},
        itemName: name,
        itemCategory: category,
        quantity: 1,
        unitPrice: price,
        notes: 'Quick add'
    };
    
    $.post('${pageContext.request.contextPath}/inspector/inspection', data, function(response) {
        if (response.success) {
            showToast('Item added successfully');
            setTimeout(() => location.reload(), 1000);
        } else {
            showToast(response.message || 'Error adding item', 'danger');
        }
    });
}

// Delete item
function deleteItem(itemId) {
    if (confirm('Are you sure you want to delete this item?')) {
        $.post('${pageContext.request.contextPath}/inspector/inspection', {
            action: 'deleteItem',
            itemId: itemId
        }, function(response) {
            if (response.success) {
                showToast('Item deleted successfully');
                setTimeout(() => location.reload(), 1000);
            }
        });
    }
}

// Delete damage
function deleteDamage(damageId) {
    if (confirm('Are you sure you want to delete this damage report?')) {
        $.post('${pageContext.request.contextPath}/inspector/inspection', {
            action: 'deleteDamage',
            damageId: damageId
        }, function(response) {
            if (response.success) {
                showToast('Damage report deleted successfully');
                setTimeout(() => location.reload(), 1000);
            }
        });
    }
}

// Save progress
function saveProgress() {
    const notes = $('#inspectionNotes').val();
    
    $.post('${pageContext.request.contextPath}/inspector/inspection', {
        action: 'saveProgress',
        inspectionId: ${inspection.id},
        notes: notes
    }, function(response) {
        if (response.success) {
            showToast('Progress saved successfully');
        }
    });
}

// Complete inspection
function completeInspection() {
    if (confirm('Are you sure you want to complete this inspection? This action cannot be undone.')) {
        $.post('${pageContext.request.contextPath}/inspector/inspection', {
            action: 'complete',
            inspectionId: ${inspection.id}
        }, function() {
            window.location.href = '${pageContext.request.contextPath}/inspector/dashboard';
        });
    }
}

// File input label update
$('.custom-file-input').on('change', function() {
    const fileName = $(this).val().split('\\').pop();
    $(this).siblings('.custom-file-label').addClass('selected').html(fileName);
});
</script>
<script>
document.getElementById("addItemForm").addEventListener("submit", function (event) {
    const quantityInput = this.querySelector('[name="quantity"]');
    const unitPriceInput = this.querySelector('[name="unitPrice"]');
    const notesInput = this.querySelector('[name="notes"]');

    const quantity = quantityInput.value.trim();
    const unitPrice = unitPriceInput.value.trim();
    const notes = notesInput.value.trim();

    let errors = [];

    // Kiểm tra độ dài ký tự
    if (quantity.length > 4) {
        errors.push("Quantity must not exceed 4 digits.");
    }

    if (unitPrice.length > 9) {
        errors.push("Unit Price must not exceed 9 digits.");
    }

    if (notes.length > 200) {
        errors.push("Notes must be less than 200 characters.");
    }

    // Kiểm tra logic giá trị
    if (parseInt(quantity) < 1 || !Number.isInteger(+quantity)) {
        errors.push("Quantity must be a positive integer (≥ 1).");
    }

    if (parseFloat(unitPrice) < 0 || isNaN(unitPrice)) {
        errors.push("Unit Price must be a positive number.");
    }

    if (errors.length > 0) {
        event.preventDefault();
        alert(errors.join("\n"));
    }
});
document.getElementById("addDamageForm").addEventListener("submit", function (event) {
    const estimatedCostInput = this.querySelector('[name="estimatedCost"]');

    const estimatedCost = estimatedCostInput.value.trim();

    let errors = [];

    // Kiểm tra độ dài ký tự 
    if (estimatedCost.length > 9) {
        errors.push("Estimated Cost must not exceed 9 digits.");
    }

    // Kiểm tra logic giá trị
    if (parseFloat(estimatedCost) < 0 || isNaN(estimatedCost)) {
        errors.push("Estimated Cost must be a positive number.");
    }

    if (errors.length > 0) {
        event.preventDefault();
        alert(errors.join("\n"));
    }
});
</script>

