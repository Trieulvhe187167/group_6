<%-- 
    Document   : room-amenity-list
    Created on : 16 thg 7, 2025, 22:47:58
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<div class="container mt-4">
    <h3 class="mb-4">Room Amenities Management</h3>

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>

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
                                $${a.unitPrice}
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </td>
                    <td>${a.createdAt}</td>
                    <td>
                        <a href="amenities?action=detail&id=${a.id}" class="btn btn-sm btn-info">View</a>
                        <a href="amenities?action=edit&id=${a.id}" class="btn btn-sm btn-warning">Edit</a>
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

    <div class="text-end">
        <a href="amenities?action=create" class="btn btn-primary">
            + Add New Amenity
        </a>
    </div>
</div>

