<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">My Inspections</li>
        </ol>
    </nav>
    <h1 class="mb-4">My Inspections</h1>
    <c:choose>
        <c:when test="${not empty myInspections}">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Room</th>
                            <th>Guest</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Status</th>
                            <th>Total Charges</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inspection" items="${myInspections}" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${inspection.reservation.roomNumber}</td>
                                <td>${inspection.reservation.customerName}</td>
                                <td><fmt:formatDate value="${inspection.reservation.checkIn}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${inspection.reservation.checkOut}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${inspection.status == 'PENDING'}">
                                            <span class="badge badge-warning">Pending</span>
                                        </c:when>
                                        <c:when test="${inspection.status == 'COMPLETED'}">
                                            <span class="badge badge-success">Completed</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${inspection.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${inspection.totalCharges}" pattern="#,#00"/>₫</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/inspector/inspection?action=view&id=${inspection.id}" class="btn btn-sm btn-primary">
                                        View Details
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="alert alert-info mt-4">You have no inspections yet.</div>
        </c:otherwise>
    </c:choose>
</div> 