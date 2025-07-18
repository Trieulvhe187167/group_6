<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>



<c:if test="${not empty error}">
    <div class="alert alert-danger" role="alert">
        ${error}
    </div>
</c:if>

<c:if test="${not empty param.success}">
    <div class="alert alert-success" role="alert">
        ${param.success}
    </div>
</c:if>


<div class="container mt-4">
    <h4 class="mb-4">
        <c:choose>
            <c:when test="${not empty amenity.id and amenity.id != 0}">
                Edit Room Amenity
            </c:when>
            <c:otherwise>
                Add New Room Amenity
            </c:otherwise>
        </c:choose>
    </h4>


    <form method="post" action="${pageContext.request.contextPath}/admin/amenities">
        <input type="hidden" name="action" value="${requestScope.formAction}" />
        <input type="hidden" name="id" value="${amenity.id}" />

        <div class="mb-3">
            <label class="form-label">Room Number</label>
            <select name="roomId" class="form-select"
                    <c:if test="${not empty amenity.id and amenity.id != 0}">disabled</c:if> required>
                        <option value="">-- Select Room --</option>
                    <c:forEach var="room" items="${roomList}">
                        <option value="${room.id}"
                                <c:if test="${amenity.roomId == room.id}">selected</c:if>>
                            ${room.roomNumber}
                        </option>
                    </c:forEach>
            </select>

            <c:if test="${not empty amenity.id and amenity.id != 0}">
                <input type="hidden" name="roomId" value="${amenity.roomId}" />
            </c:if>
        </div>

        <div class="mb-3">
            <label class="form-label">Amenity Name</label>
            <input type="text" name="name" class="form-control"
                   value="${amenity.name}" required />
        </div>

        <div class="mb-3">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3">${amenity.description}</textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">Chargeable</label>
            <select name="isChargeable" class="form-select">
                <option value="true" ${amenity.isChargeable == true ? 'selected' : ''}>Yes</option>
                <option value="false" ${amenity.isChargeable == false ? 'selected' : ''}>No</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Unit Price (VND)</label>
            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice"
                   value="${amenity.unitPrice}" required />
        </div>

        <button type="submit" class="btn btn-primary">
            <c:choose>
                <c:when test="${not empty amenity.id and amenity.id != 0}">
                    Update Amenity
                </c:when>
                <c:otherwise>
                    Add Amenity
                </c:otherwise>
            </c:choose>
        </button>

        <a href="${pageContext.request.contextPath}/admin/amenities?action=list" class="btn btn-secondary ms-2">Cancel</a>
    </form>

</div>