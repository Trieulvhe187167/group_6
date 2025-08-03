<%-- 
    Document   : support-list
    Created on : 2 thg 8, 2025, 20:02:17
    Author     : ASUS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>


<div class="container mt-4">
    <h2 class="mb-4">Support Requests</h2>

    <!-- Filter & Sort Form -->
    <form method="get" action="support" class="d-flex flex-wrap justify-content-between align-items-center mb-3">

        <!-- Sort Options -->
        <div class="form-group mr-3">
            <label for="sortBy">Sort By:</label>
            <select id="sortBy" name="sortBy" class="form-control" style="min-width: 150px;" onchange="this.form.submit()">
                <option value="createdAt" ${sortBy == 'createdAt' ? 'selected' : ''}>Created At</option>
                <option value="requestId" ${sortBy == 'requestId' ? 'selected' : ''}>Request ID</option>
            </select>
        </div>

        <!-- Filter by Room -->
        <div class="form-group mr-3">
            <label for="filterRoom">Filter by Room:</label>
            <select name="filterRoom" id="filterRoom" class="form-control" style="min-width: 150px;" onchange="this.form.submit()">
                <option value="">All</option>
                <c:forEach var="room" items="${roomList}">
                    <option value="${room}" ${room == filterRoom ? 'selected' : ''}>${room}</option>
                </c:forEach>
            </select>
        </div>

        <!-- Filter by Status -->
        <div class="form-group">
            <label for="filterStatus">Filter by Status:</label>
            <select name="filterStatus" id="filterStatus" class="form-control" style="min-width: 150px;" onchange="this.form.submit()">
                <option value="">All</option>
                <option value="Pending" ${filterStatus == 'Pending' ? 'selected' : ''}>Pending</option>
                <option value="In Progress" ${filterStatus == 'In Progress' ? 'selected' : ''}>In Progress</option>
                <option value="Resolved" ${filterStatus == 'Resolved' ? 'selected' : ''}>Resolved</option>
                <option value="Rejected" ${filterStatus == 'Rejected' ? 'selected' : ''}>Rejected</option>
            </select>
        </div>
    </form>

    <table class="table table-bordered table-hover">
        <thead class="thead-dark">
            <tr>
                <th>ID</th>
                <th>Room</th>
                <th>User</th>
                <th>Title</th>
                <th>Status</th>
                <th>Created At</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="sr" items="${requestList}">
                <tr>
                    <td>${sr.id}</td>
                    <td>${sr.roomNumber}</td>
                    <td>${sr.userName}</td>
                    <td>${sr.title}</td>
                    <td>
                        <span class="badge
                              <c:choose>
                                  <c:when test="${sr.status eq 'Pending'}">bg-warning</c:when>
                                  <c:when test="${sr.status eq 'In Progress'}">bg-info text-white</c:when>
                                  <c:when test="${sr.status eq 'Resorved'}">bg-success</c:when>
                                  <c:when test="${sr.status eq 'Rejected'}">bg-danger text-white</c:when>
                                  <c:otherwise>badge-secondary</c:otherwise>
                              </c:choose>
                              ">
                            ${sr.status}
                        </span>
                    </td>
                    <td><fmt:formatDate value="${sr.createdAt}" pattern="yyyy-MM-dd HH:mm" /></td>
                    <td>
                        <a href="support?action=detail&id=${sr.id}" class="btn btn-sm btn-info">View</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <c:if test="${empty requestList}">
        <p class="text-muted">No support requests found.</p>
    </c:if>

    <c:if test="${totalPages > 1}">
        <nav>
            <ul class="pagination justify-content-center">
                <c:forEach var="i" begin="1" end="${totalPages}">
                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}&filterRoom=${filterRoom}&filterStatus=${filterStatus}&sortBy=${sortBy}">
                            ${i}
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
    </c:if>

</div>

<script>
    function getFilterParams() {
        const sortBy = document.getElementById("sortBy").value;
        const room = document.getElementById("filterRoom").value;
        const status = document.getElementById("filterStatus").value;

        const params = new URLSearchParams();
        if (sortBy)
            params.append("sortBy", sortBy);
        if (room)
            params.append("room", room);
        if (status)
            params.append("status", status);

        return params.toString();
    }

    function sortChanged() {
        const params = getFilterParams();
        window.location.href = "support?" + params;
    }

    function filterChanged() {
        const params = getFilterParams();
        window.location.href = "support?" + params;
    }
</script>
