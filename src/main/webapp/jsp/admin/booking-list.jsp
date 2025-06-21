<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="admin-layout.jsp" />

<div class="container-fluid">
    <h2 class="mb-4">Booking Management</h2>
    
    <div class="table-responsive">
        <table class="table table-bordered table-hover">
            <thead class="thead-dark">
                <tr>
                    <th>#</th>
                    <th>Customer</th>
                    <th>Room</th>
                    <th>Check-In</th>
                    <th>Check-Out</th>
                    <th>Status</th>
                    <th>Total</th>
                    <th>Created At</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="b" items="${reservations}" varStatus="i">
                    <tr>
                        <td>${i.count}</td>
                        <td>${b.userFullName}</td>
                        <td>${b.roomName}</td>
                        <td><fmt:formatDate value="${b.checkIn}" pattern="yyyy-MM-dd"/></td>
                        <td><fmt:formatDate value="${b.checkOut}" pattern="yyyy-MM-dd"/></td>
                        <td>
                            <span class="badge 
                                <c:choose>
                                    <c:when test="${b.status == 'CONFIRMED'}">badge-success</c:when>
                                    <c:when test="${b.status == 'PENDING'}">badge-warning</c:when>
                                    <c:otherwise>badge-secondary</c:otherwise>
                                </c:choose>">
                                ${b.status}
                            </span>
                        </td>
                        <td><fmt:formatNumber value="${b.totalAmount}" pattern="#,##0"/> ₫</td>
                        <td><fmt:formatDate value="${b.createdAt}" pattern="yyyy-MM-dd"/></td>
                        <td>
                            <a href="booking-detail.jsp?id=${b.id}" class="btn btn-sm btn-info">Detail</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>
