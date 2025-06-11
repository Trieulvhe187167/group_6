<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .form-container {
        max-width: 900px;
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .form-section {
        margin-bottom: 30px;
    }

    .form-section h3 {
        color: #5a2b81;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 2px solid #f0f0f0;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 500;
        color: #4a5568;
        width: 100%;
    }

    .form-control {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #e9ecef;
        border-radius: 5px;
        font-size: 14px;
        transition: border-color 0.3s;
        height: auto;
        min-height: 44px;
        line-height: 1.5;
    }

    .form-control:focus {
        outline: none;
        border-color: #5a2b81;
        box-shadow: 0 0 0 0.2rem rgba(90, 43, 129, 0.25);
    }

    .form-control.is-invalid {
        border-color: #dc3545;
    }

    select.form-control {
        cursor: pointer;
        padding-right: 30px;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }

    .btn {
        padding: 12px 24px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.3s;
        min-height: 44px;
    }

    .btn-primary {
        background: #5a2b81;
        color: white;
    }

    .btn-primary:hover {
        background: #4a1f6d;
        color: white;
        text-decoration: none;
    }

    .btn-secondary {
        background: #6c757d;
        color: white;
    }

    .btn-secondary:hover {
        background: #5a6268;
        color: white;
        text-decoration: none;
    }

    .text-danger {
        color: #dc3545;
    }

    .text-muted {
        color: #6c757d;
        font-size: 0.875rem;
    }

    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
    }

    .alert-danger {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    .info-box {
        background: #f8f9fa;
        border-left: 4px solid #5a2b81;
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
    }

    .info-box h6 {
        margin-bottom: 10px;
        color: #5a2b81;
    }

    .info-box ul {
        margin-bottom: 0;
        padding-left: 20px;
    }

    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms">Room Types</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit Room Type' : 'Create Room Type'}</li>
        </ol>
    </nav>

    <h1 class="mb-4">${isEdit ? 'Edit' : 'Create New'} Room Type</h1>

    <div class="row">
        <div class="col-lg-8">
            <div class="form-container">
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/rooms" id="roomTypeForm">
                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="id" value="${roomType.id}">
                    </c:if>

                    <!-- Basic Information -->
                    <div class="form-section">
                        <h3><i class="fas fa-info-circle"></i> Basic Information</h3>

                        <div class="form-group">
                            <label for="name">Room Type Name <span class="text-danger">*</span></label>
                            <input name="name" type="text" required 
                                   class="form-control" id="name"
                                   placeholder="Enter room type name"
                                   value="${isEdit ? roomType.name : ''}">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="basePrice">Base Price (₫/night) <span class="text-danger">*</span></label>
                                <input name="basePrice" type="number" required 
                                       class="form-control" id="basePrice"
                                       placeholder="Enter base price"
                                       min="0" step="1000"
                                       value="${isEdit ? roomType.basePrice : ''}">
                            </div>
                            <div class="form-group">
                                <label for="capacity">Capacity (guests) <span class="text-danger">*</span></label>
                                <input name="capacity" type="number" required 
                                       class="form-control" id="capacity"
                                       placeholder="Enter max capacity"
                                       min="1" max="10"
                                       value="${isEdit ? roomType.capacity : ''}">
                            </div>
                        </div>

                        <c:if test="${isEdit}">
                            <div class="form-group">
                                <label for="status">Status <span class="text-danger">*</span></label>
                                <select name="status" class="form-control" id="status" required>
                                    <option value="active" ${roomType.status == 'active' ? 'selected' : ''}>Active</option>
                                    <option value="inactive" ${roomType.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                                </select>
                            </div>
                        </c:if>
                    </div>

                    <!-- Room Details -->
                    <div class="form-section">
                        <h3><i class="fas fa-bed"></i> Room Details</h3>

                        <div class="form-group">
                            <label for="imageUrl">Image URL <span class="text-danger">*</span></label>
                            <input name="imageUrl" type="text" required 
                                   class="form-control" id="imageUrl"
                                   placeholder="Enter image filename (e.g., room1.jpg)"
                                   value="${isEdit ? roomType.imageUrl : ''}">
                            <small class="text-muted">Image should be placed in /assets/images/uploads/ folder</small>
                        </div>

                        <div class="form-group">
                            <label for="bed">Bed Type <span class="text-danger">*</span></label>
                            <select name="bed" class="form-control" id="bed" required>
                                <option value="">Select bed type</option>
                                <option value="Single Bed">Single Bed</option>
                                <option value="Double Bed">Double Bed</option>
                                <option value="Queen Bed">Queen Bed</option>
                                <option value="King Bed">King Bed</option>
                                <option value="Twin Beds">Twin Beds</option>
                                <option value="Bunk Bed">Bunk Bed</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="description">Description <span class="text-danger">*</span></label>
                            <textarea name="description" required 
                                      class="form-control" id="description" rows="4"
                                      placeholder="Enter room type description">${isEdit ? roomType.description : ''}</textarea>
                        </div>

                        <div class="form-group">
                            <label for="special">Special Features</label>
                            <textarea name="special" 
                                      class="form-control" id="special" rows="3"
                                      placeholder="Enter special features (e.g., Ocean view, Balcony, Jacuzzi)"></textarea>
                            <small class="text-muted">Optional: List any special amenities or features</small>
                        </div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} Room Type
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Side Information -->
        <div class="col-lg-4">
            <div class="info-box">
                <h6><i class="fas fa-lightbulb"></i> Room Type Guidelines</h6>
                <ul class="small">
                    <li><strong>Name:</strong> Use descriptive names (e.g., "Deluxe Ocean View")</li>
                    <li><strong>Price:</strong> Set competitive rates based on market research</li>
                    <li><strong>Capacity:</strong> Maximum number of guests allowed</li>
                    <li><strong>Images:</strong> Use high-quality photos showcasing the room</li>
                </ul>
            </div>

            <div class="info-box">
                <h6><i class="fas fa-bed"></i> Bed Type Guide</h6>
                <ul class="small">
                    <li><strong>Single:</strong> 90cm x 190cm (1 person)</li>
                    <li><strong>Double:</strong> 135cm x 190cm (2 people)</li>
                    <li><strong>Queen:</strong> 150cm x 200cm (2 people)</li>
                    <li><strong>King:</strong> 180cm x 200cm (2 people)</li>
                    <li><strong>Twin:</strong> Two single beds</li>
                </ul>
            </div>

            <c:if test="${isEdit}">
                <div class="info-box">
                    <h6><i class="fas fa-info"></i> Room Type Information</h6>
                    <p class="small mb-1">
                        <strong>ID:</strong> ${roomType.id}
                    </p>
                    <p class="small mb-1">
                        <strong>Created:</strong> 
                        <fmt:formatDate value="${roomType.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                    <p class="small mb-0">
                        <strong>Last Updated:</strong> 
                        <c:choose>
                            <c:when test="${roomType.updatedAt != null}">
                                <fmt:formatDate value="${roomType.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </c:when>
                            <c:otherwise>
                                Never updated
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:if>

            <div class="info-box">
                <h6><i class="fas fa-image"></i> Image Requirements</h6>
                <ul class="small">
                    <li>Recommended size: 800x600 pixels</li>
                    <li>Format: JPG, PNG, WebP</li>
                    <li>Max file size: 2MB</li>
                    <li>Good lighting and composition</li>
                    <li>Show room's best features</li>
                </ul>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(document).ready(function() {
    // Form validation
    $('#roomTypeForm').on('submit', function(e) {
        var isValid = true;
        var errorMessage = '';

        // Clear previous validation states
        $('.form-control').removeClass('is-invalid');

        // Check required fields
        $(this).find('[required]').each(function() {
            if (!$(this).val().trim()) {
                $(this).addClass('is-invalid');
                isValid = false;
            }
        });

        // Validate price
        var price = $('#basePrice').val();
        if (price && (isNaN(price) || parseFloat(price) <= 0)) {
            $('#basePrice').addClass('is-invalid');
            errorMessage = 'Price must be a positive number';
            isValid = false;
        }

        // Validate capacity
        var capacity = $('#capacity').val();
        if (capacity && (isNaN(capacity) || parseInt(capacity) <= 0 || parseInt(capacity) > 10)) {
            $('#capacity').addClass('is-invalid');
            errorMessage = 'Capacity must be between 1 and 10';
            isValid = false;
        }

        // Validate image URL
        var imageUrl = $('#imageUrl').val();
        if (imageUrl && !/\.(jpg|jpeg|png|gif|webp)$/i.test(imageUrl)) {
            $('#imageUrl').addClass('is-invalid');
            errorMessage = 'Image URL must end with a valid image extension (.jpg, .png, etc.)';
            isValid = false;
        }

        if (!isValid) {
            e.preventDefault();
            if (errorMessage) {
                alert(errorMessage);
            } else {
                alert('Please fill in all required fields');
            }
        }
    });

    // Remove invalid class on input
    $('.form-control').on('input change', function() {
        $(this).removeClass('is-invalid');
    });

    // Auto-format price input
    $('#basePrice').on('input', function() {
        var value = $(this).val().replace(/[^\d]/g, '');
        if (value) {
            $(this).val(parseInt(value));
        }
    });

    // If editing, populate fields from description
    <c:if test="${isEdit && not empty roomType.description}">
        var description = "${roomType.description}";
        var parts = description.split(',');
        
        if (parts.length > 1) {
            // Set bed type
            var bedType = parts[1].trim();
            $('#bed').val(bedType);
            
            // Set description (first part)
            $('#description').val(parts[0].trim());
            
            // Set special features (remaining parts)
            if (parts.length > 2) {
                var special = '';
                for (var i = 2; i < parts.length; i++) {
                    if (i > 2) special += ', ';
                    special += parts[i].trim();
                }
                $('#special').val(special);
            }
        } else {
            // If no comma separation, put everything in description
            $('#description').val(description);
        }
    </c:if>
});
</script>