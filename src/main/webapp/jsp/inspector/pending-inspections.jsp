<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Pending Inspections</li>
        </ol>
    </nav>
    <h1 class="mb-4">Pending Inspections</h1>
    <c:choose>
        <c:when test="${not empty pendingInspections}">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Room</th>
                            <th>Guest</th>
                            <th>Check-out</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="reservation" items="${pendingInspections}">
                            <tr>
                                <td>${reservation.roomNumber} <br><small>${reservation.roomTypeName}</small></td>
                                <td>${reservation.customerName} <br><small>${reservation.customerPhone}</small></td>
                                <td><fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/></td>
                                <td><span class="badge badge-warning">Pending</span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/inspector/inspection?action=start&reservationId=${reservation.id}" class="btn btn-sm btn-primary">
                                        <i class="fas fa-clipboard-check"></i> Start Inspection
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="alert alert-info mt-4">No pending inspections at the moment.</div>
        </c:otherwise>
    </c:choose>
</div> 