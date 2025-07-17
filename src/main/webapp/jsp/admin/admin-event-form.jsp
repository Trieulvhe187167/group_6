<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/events">Event Management</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit' : 'Add'} Event</li>
        </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>${isEdit ? 'Edit' : 'Add New'} Event</h1>
        <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>

    <!-- Error Messages -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>

    <!-- Event Form -->
    <div class="card">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/events" 
                  enctype="multipart/form-data" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${event.id}">
                </c:if>

                <div class="row">
                    <div class="col-md-8">
                        <!-- Title -->
                        <div class="form-group">
                            <label for="title">Title <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" 
                                   value="${event.title}" required maxlength="200"
                                   placeholder="Enter event title">
                            <small class="form-text text-muted">Maximum 200 characters</small>
                        </div>

                        <!-- Description -->
                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea class="form-control" id="description" name="description" 
                                      rows="5" placeholder="Enter event description">${event.description}</textarea>
                        </div>

                        <!-- Location -->
                        <div class="form-group">
                            <label for="location">Location</label>
                            <input type="text" class="form-control" id="location" name="location" 
                                   value="${event.location}" maxlength="200"
                                   placeholder="Enter event location">
                        </div>

                        <!-- Date and Time -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <input type="date" name="startDate" id="startDate" value="${event.startDate}" required>
                                    <input type="date" name="endDate" id="endDate" value="${event.endDate}" required>

                                </div>
                            </div>
                        </div>  
                    </div>

                    <div class="col-md-4">
                        <!-- Status -->
                        <div class="form-group">
                            <label for="status">Status <span class="text-danger">*</span></label>
                            <select class="form-control" id="status" name="status" required>
                                <option value="SCHEDULED" ${event.status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                                <option value="ONGOING" ${event.status == 'ONGOING' ? 'selected' : ''}>Ongoing</option>
                                <option value="COMPLETED" ${event.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="CANCELLED" ${event.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                            </select>
                        </div>

                        <!-- Featured Image -->
                        <div class="form-group">
                            <label for="image">Event Image</label>

                            <c:if test="${isEdit && not empty event.imageUrl}">
                                <div class="mb-2">
                                    <img src="${pageContext.request.contextPath}/assets/images/uploads/events/${event.imageUrl}" 
                                         alt="Current image" class="img-fluid img-thumbnail">
                                    <small class="d-block text-muted mt-1">Current image</small>
                                </div>
                            </c:if>

                            <div class="custom-file">
                                <input type="file" class="custom-file-input" id="image" name="image"
                                       accept="image/*" onchange="previewImage(this)">
                                <label class="custom-file-label" for="image">Choose image</label>
                            </div>
                            <small class="form-text text-muted">
                                Recommended size: 1200x600px. Max 5MB. JPG, PNG, GIF
                            </small>

                            <!-- Image Preview -->
                            <div id="imagePreview" class="mt-2" style="display: none;">
                                <img id="preview" src="" alt="Preview" class="img-fluid img-thumbnail">
                            </div>
                        </div>

                        <!-- Event Information -->
                        <div class="card bg-light">
                            <div class="card-body">
                                <h6 class="card-title">Information</h6>
                                <c:if test="${isEdit}">
                                    <p class="mb-1">
                                        <small><strong>Created:</strong> 
                                            <fmt:formatDate value="${event.createdAt}" 
                                                            pattern="dd/MM/yyyy HH:mm"/>
                                        </small>
                                    </p>
                                    <p class="mb-1">
                                        <small><strong>Updated:</strong> 
                                            <fmt:formatDate value="${event.updatedAt}" 
                                                            pattern="dd/MM/yyyy HH:mm"/>
                                        </small>
                                    </p>
                                    <c:if test="${not empty event.createdBy}">
                                        <p class="mb-0">
                                            <small><strong>Created By:</strong> User #${event.createdBy}</small>
                                        </p>
                                    </c:if>
                                </c:if>
                                <c:if test="${not isEdit}">
                                    <p class="mb-0 text-muted">
                                        <small>Event will be created with current date and time</small>
                                    </p>
                                </c:if>
                            </div>
                        </div>

                        <!-- Quick Tips -->
                        <div class="card bg-info text-white mt-3">
                            <div class="card-body">
                                <h6 class="card-title">Quick Tips</h6>
                                <ul class="mb-0 pl-3">
                                    <li><small>Set status to "Scheduled" for future events</small></li>
                                    <li><small>Events can be marked as "Ongoing" when they start</small></li>
                                    <li><small>Remember to update status when event ends</small></li>
                                    <li><small>Cancelled events remain in history</small></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Form Actions -->
                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} Event
                    </button>
                    <button type="submit" name="saveAndContinue" value="true" class="btn btn-success">
                        <i class="fas fa-save"></i> Save & Continue Editing
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Preview image before upload
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('preview').src = e.target.result;
                document.getElementById('imagePreview').style.display = 'block';
            }
            reader.readAsDataURL(input.files[0]);

            // Update label with filename
            var fileName = input.files[0].name;
            var label = input.nextElementSibling;
            label.textContent = fileName;
        }
    }

// Form validation
    function validateForm() {
        var startAt = new Date(document.getElementById('startAt').value);
        var endAt = new Date(document.getElementById('endAt').value);

        if (endAt <= startAt) {
            alert('End date/time must be after start date/time');
            return false;
        }

        // Check if event is in the past (for new events)
    <c:if test="${not isEdit}">
        var now = new Date();
        if (startAt < now) {
            if (!confirm('The start date/time is in the past. Are you sure you want to continue?')) {
                return false;
            }
        }
    </c:if>

        return true;
    }

// Set minimum date for datetime inputs (current datetime)
    $(document).ready(function () {
        var now = new Date();
        var minDateTime = now.toISOString().slice(0, 16);

    <c:if test="${not isEdit}">
        // For new events, set minimum to current datetime
        $('#startAt').attr('min', minDateTime);
        $('#endAt').attr('min', minDateTime);
    </c:if>

        // Update end date minimum when start date changes
        $('#startAt').on('change', function () {
            var startDate = $(this).val();
            if (startDate) {
                $('#endAt').attr('min', startDate);
                // If end date is before start date, clear it
                if ($('#endAt').val() && $('#endAt').val() < startDate) {
                    $('#endAt').val('');
                }
            }
        });
    });

    window.addEventListener('DOMContentLoaded', function () {
        const today = new Date().toISOString().split('T')[0];

        const startInput = document.getElementById('startDate');
        const endInput = document.getElementById('endDate');

        if (startInput) {
            startInput.setAttribute('min', today);
        }

        if (endInput) {
            endInput.setAttribute('min', today);
        }

        // Nếu có logic: ngày kết thúc không được nhỏ hơn ngày bắt đầu
        if (startInput && endInput) {
            startInput.addEventListener('change', function () {
                endInput.min = startInput.value;
            });
        }
    });
</script>