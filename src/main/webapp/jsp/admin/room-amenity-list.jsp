<%-- 
    Document   : room-amenity-list
    Created on : 16 thg 7, 2025, 22:47:58
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>



<div class="container mt-4">
    <h3 class="mb-4">Room Amenities Management</h3>

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>


    <!-- FILTER FORM -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <form class="row g-2 align-items-end" method="get" action="${pageContext.request.contextPath}/admin/amenities">
                <input type="hidden" name="action" value="list" />

                <!-- Room Number -->
                <div class="col-lg-3 col-md-6">
                    <label for="roomNumber" class="form-label fw-semibold mb-1">Room</label>
                    <select class="form-select form-select-sm" id="roomNumber" name="roomNumber">
                        <option value="">All Rooms</option>
                        <c:forEach var="room" items="${roomList}">
                            <option value="${room.roomNumber}" <c:if test="${param.roomNumber == room.roomNumber}">selected</c:if>>
                                ${room.roomNumber}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Amenity Name -->
                <div class="col-lg-3 col-md-6">
                    <label for="amenityName" class="form-label fw-semibold mb-1">Amenity</label>
                    <select class="form-select form-select-sm" id="amenityName" name="amenityName">
                        <option value="">All Amenities</option>
                        <c:forEach var="amenityName" items="${amenityNameList}">
                            <option value="${amenityName}" <c:if test="${param.amenityName == amenityName}">selected</c:if>>
                                ${amenityName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Keyword -->
                <div class="col-lg-4 col-md-8">
                    <label for="keyword" class="form-label fw-semibold mb-1">Search</label>
                    <input type="text" class="form-control form-control-sm" id="keyword" name="keyword"
                           value="${param.keyword}" placeholder="e.g. minibar, kettle...">
                </div>

                <!-- Filter Button -->
                <div class="col-lg-2 col-md-4 text-end">
                    <label class="form-label fw-semibold mb-1 d-none d-md-block">&nbsp;</label>
                    <button type="submit" class="btn btn-sm btn-outline-primary w-100">
                        <i class="fas fa-search me-1"></i> Search
                    </button>
                </div>
            </form>

            <a href="${pageContext.request.contextPath}/admin/amenities?action=add" class="btn btn-success ml-auto">
                <i class="fas fa-plus"></i> Add Amenity
            </a>

        </div>
    </div>


    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">  

                <!-- Pagination summary -->
                <div class="mb-3 text-muted">
                    <small>
                        Showing ${((currentPage - 1) * recordsPerPage) + 1}
                        -
                        ${currentPage * recordsPerPage > totalRecords ? totalRecords : currentPage * recordsPerPage}
                        of ${totalRecords} amenities
                    </small>

                </div>

                <!-- Amenities Table -->
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Room Number</th>
                            <th>Amenity Name</th>
                            <th>Description</th>
                            <th>Chargeable</th>
                            <th>Unit Price</th>
                            <th>Created At</th>
                            <th style="width: 150px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${amenities}">
                            <tr>
                                <td>${a.roomNumber}</td>
                                <td>${a.name}</td>
                                <td>${a.description}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.isChargeable}">Yes</c:when>
                                        <c:otherwise>No</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.isChargeable}">
                                            ${a.unitPrice}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${a.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="${pageContext.request.contextPath}/admin/amenities?action=detail&id=${a.id}" 
                                           class="btn btn-sm btn-info text-white" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/amenities?action=edit&id=${a.id}" 
                                           class="btn btn-sm btn-warning text-white" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/amenities?action=delete&id=${a.id}" 
                                           class="btn btn-sm btn-danger text-white" title="Delete"
                                           onclick="return confirm('Are you sure you want to delete this amenity?');">
                                            <i class="fas fa-trash"></i>
                                        </a>
                                    </div>
                                </td>

                            </tr>
                        </c:forEach>

                        <c:if test="${empty amenities}">
                            <tr>
                                <td colspan="7" class="text-center text-muted">No amenities found.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>


    <!-- Pagination -->            
    <c:if test="${totalPages > 1}">
        <nav aria-label="Page navigation">
            <ul class="pagination justify-content-center">
                <c:if test="${currentPage > 1}">
                    <li class="page-item">
                        <a class="page-link"
                           href="?page=${currentPage - 1}&keyword=${param.keyword}&roomNumber=${param.roomNumber}&amenityName=${param.amenityName}"
                           aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                </c:if>

                <c:set var="start" value="${currentPage - 2}" />
                <c:set var="end" value="${currentPage + 2}" />
                <c:if test="${start < 2}">
                    <c:set var="start" value="1" />
                    <c:set var="end" value="5" />
                </c:if>
                <c:if test="${end > totalPages - 1}">
                    <c:set var="end" value="${totalPages}" />
                    <c:set var="start" value="${totalPages - 4}" />
                    <c:if test="${start < 1}">
                        <c:set var="start" value="1" />
                    </c:if>
                </c:if>

                <!-- Always show page 1 -->
                <li class="page-item ${1 == currentPage ? 'active' : ''}">
                    <a class="page-link"
                       href="?page=1&keyword=${param.keyword}&roomNumber=${param.roomNumber}&amenityName=${param.amenityName}">1</a>
                </li>

                <!-- Show ... if needed -->
                <c:if test="${start > 2}">
                    <li class="page-item disabled"><span class="page-link">...</span></li>
                    </c:if>

                <!-- Middle pages -->
                <c:forEach var="i" begin="${start}" end="${end}">
                    <c:if test="${i != 1 && i != totalPages}">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link"
                               href="?page=${i}&keyword=${param.keyword}&roomNumber=${param.roomNumber}&amenityName=${param.amenityName}">${i}</a>
                        </li>
                    </c:if>
                </c:forEach>

                <!-- Show ... if needed -->
                <c:if test="${end < totalPages - 1}">
                    <li class="page-item disabled"><span class="page-link">...</span></li>
                    </c:if>

                <!-- Always show last page if it's not already shown -->
                <c:if test="${totalPages > 1}">
                    <li class="page-item ${totalPages == currentPage ? 'active' : ''}">
                        <a class="page-link"
                           href="?page=${totalPages}&keyword=${param.keyword}&roomNumber=${param.roomNumber}&amenityName=${param.amenityName}">${totalPages}</a>
                    </li>
                </c:if>

                <c:if test="${currentPage < totalPages}">
                    <li class="page-item">
                        <a class="page-link"
                           href="?page=${currentPage + 1}&keyword=${param.keyword}&roomNumber=${param.roomNumber}&amenityName=${param.amenityName}"
                           aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </c:if>


</div>

<script>
    document.getElementById("roomNumber").addEventListener("change", function () {
        this.form.submit();
    });

    document.getElementById("amenityName").addEventListener("change", function () {
        this.form.submit();
    });
</script>

