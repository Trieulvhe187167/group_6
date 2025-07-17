<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger">
        ${param.error}
    </div>
</c:if>


<div class="container mt-4">
    <h4 class="mb-4">
        <c:choose>
            <c:when test="${not empty amenity.id}">
                Edit Room Amenity
            </c:when>
            <c:otherwise>
                Add New Room Amenity
            </c:otherwise>
        </c:choose>
    </h4>

    <form method="post" action="${pageContext.request.contextPath}/admin/amenities">
        <!-- Action: Add or Edit -->
        <input type="hidden" name="action" value="${empty amenity.id ? 'add' : 'edit'}" />
        <input type="hidden" name="id" value="${amenity.id}" />

        <!-- Room Number -->
        <div class="mb-3">
            <label class="form-label">Room Number</label>
            <select name="roomId" class="form-select" 
                    <c:if test="${not empty amenity and amenity.id != 0}">disabled</c:if> required>
                        <option value="">-- Select Room --</option>
                    <c:forEach var="room" items="${roomList}">
                        <option value="${room.id}"
                                <c:if test="${sessionScope.roomId == room.id}">selected</c:if>>
                            ${room.roomNumber}
                        </option>
                    </c:forEach>
            </select>

            <!-- Hidden field for roomId when editing -->
            <c:if test="${not empty amenity and amenity.id != 0}">
                <input type="hidden" name="roomId" value="${amenity.roomId}" />
            </c:if>
        </div>

        <!-- Amenity Name -->
        <div class="mb-3">
            <label class="form-label">Amenity Name</label>
            <input type="text" name="name" class="form-control" 
                   value="${sessionScope.name != null ? sessionScope.name : ''}" required />
        </div>

        <!-- Description -->
        <div class="mb-3">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3">${sessionScope.description != null ? sessionScope.description : ''}</textarea>
        </div>

        <!-- Is Chargeable -->
        <div class="mb-3">
            <label class="form-label">Chargeable</label>
            <select name="isChargeable" class="form-select">
                <option value="true" ${sessionScope.isChargeable == 'true' ? 'selected' : ''}>Yes</option>
                <option value="false" ${sessionScope.isChargeable == 'false' ? 'selected' : ''}>No</option>
            </select>
        </div>

        <!-- Unit Price -->
        <div class="mb-3">
            <label class="form-label">Unit Price (VND)</label>
            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice"
                   value="${sessionScope.unitPrice != null ? sessionScope.unitPrice : ''}" required />
        </div>

        <!-- Submit Button -->
        <button type="submit" class="btn btn-primary">
            <c:choose>
                <c:when test="${not empty amenity.id}">
                    Update Amenity
                </c:when>
                <c:otherwise>
                    Add Amenity
                </c:otherwise>
            </c:choose>
        </button>

        <!-- Cancel Button -->
        <a href="${pageContext.request.contextPath}/admin/amenities?action=list" class="btn btn-secondary ms-2">Cancel</a>
    </form>

</div>