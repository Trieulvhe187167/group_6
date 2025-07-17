<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle}</title>
    <!-- Include Bootstrap CSS or any other stylesheets you use -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet">
</head>
<body>

    <div class="container mt-4">
        <h3 class="mb-4">${pageTitle}</h3>

        <!-- Display Error Message if any -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <!-- Amenity Info Card -->
        <div class="card">
            <div class="card-header">
                <h4 class="card-title">Amenity Information</h4>
            </div>
            <div class="card-body">
                <dl class="row">
                    <!-- Room Number -->
                    <dt class="col-sm-3">Room Number</dt>
                    <dd class="col-sm-9">${roomAmenity.roomNumber}</dd>

                    <!-- Amenity Name -->
                    <dt class="col-sm-3">Amenity Name</dt>
                    <dd class="col-sm-9">${roomAmenity.name}</dd>

                    <!-- Description -->
                    <dt class="col-sm-3">Description</dt>
                    <dd class="col-sm-9">${roomAmenity.description}</dd>

                    <!-- Chargeable Status -->
                    <dt class="col-sm-3">Chargeable</dt>
                    <dd class="col-sm-9">
                        <c:choose>
                            <c:when test="${roomAmenity.isChargeable}">Yes</c:when>
                            <c:otherwise>No</c:otherwise>
                        </c:choose>
                    </dd>

                    <!-- Unit Price -->
                    <dt class="col-sm-3">Unit Price</dt>
                    <dd class="col-sm-9">
                        <c:choose>
                            <c:when test="${roomAmenity.isChargeable}">${roomAmenity.unitPrice}</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </dd>

                    <!-- Created At -->
                    <dt class="col-sm-3">Created At</dt>
                    <dd class="col-sm-9">
                        <fmt:formatDate value="${roomAmenity.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                    </dd>

                </dl>
            </div>
        </div>

        <!-- Buttons -->
        <div class="mt-4">
            <!-- Edit Button -->
            <a href="${pageContext.request.contextPath}/admin/amenities?action=edit&id=${roomAmenity.id}" class="btn btn-warning text-white">
                <i class="fas fa-edit"></i> Edit
            </a>

            <!-- Delete Button -->
            <a href="${pageContext.request.contextPath}/admin/amenities?action=delete&id=${roomAmenity.id}" class="btn btn-danger text-white"
               onclick="return confirm('Are you sure you want to delete this amenity?');">
                <i class="fas fa-trash"></i> Delete
            </a>

            <!-- Back to List Button -->
            <a href="${pageContext.request.contextPath}/admin/amenities" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>

    <!-- Include Bootstrap JS and Font Awesome for icons -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
