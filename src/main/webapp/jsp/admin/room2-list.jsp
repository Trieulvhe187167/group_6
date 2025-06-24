<%-- 
    Document   : room2-list
    Created on : 22 thg 6, 2025, 21:39:27
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="container mt-4">
    <h2>Room List</h2>

    <form method="get" action="rooms2" class="mb-3 row g-3">
        <input type="hidden" name="action" value="list"/>
        <div class="col-md-3">
            <input type="text" name="keyword" placeholder="Search by room number" class="form-control" value="${keyword}" />
        </div>
        <div class="col-md-2">
            <select name="roomTypeId" class="form-select">
                <option value="">All Types</option>
                <c:forEach var="type" items="${roomTypes}">
                    <option value="${type.id}" ${type.id == selectedRoomTypeId ? 'selected' : ''}>${type.name}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <input type="number" name="capacity" placeholder="Capacity" class="form-control" value="${selectedCapacity}" />
        </div>
        <div class="col-md-2">
            <select name="status" class="form-select">
                <option value="">All Status</option>
                <option value="Available" ${selectedStatus == 'Available' ? 'selected' : ''}>Available</option>
                <option value="Occupied" ${selectedStatus == 'Occupied' ? 'selected' : ''}>Occupied</option>
                <option value="Maintenance" ${selectedStatus == 'Maintenance' ? 'selected' : ''}>Maintenance</option>
            </select>
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary">Filter</button>
        </div>
    </form>

    <a href="rooms2?action=form" class="btn btn-success mb-3">Add New Room</a>

    <table class="table table-bordered table-hover">
        <thead class="table-light">
            <tr>
                <th>#</th>
                <th>Room Number</th>
                <th>Room Type</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="room" items="${rooms}" varStatus="loop">
                <tr>
                    <td>${(currentPage - 1) * recordsPerPage + loop.index + 1}</td>
                    <td>${room.roomNumber}</td>
                    <td>${room.roomType.name}</td>
                    <td>${room.status}</td>
                    <td>
                        <a href="rooms2?action=view&id=${room.id}" class="btn btn-info btn-sm">View</a>
                        <a href="rooms2?action=update&id=${room.id}" class="btn btn-warning btn-sm">Edit</a>
                        <form action="rooms2" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="id" value="${room.id}"/>
                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure to delete?')">Delete</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <!-- Pagination -->
    <nav>
        <ul class="pagination">
            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                    <a class="page-link" href="rooms2?page=${i}">${i}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</div>
