<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Housekeeping</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Housekeeping - Room Status Management</h1>
    
    <!-- Filter Form -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/HouseKeeping" class="form-inline">
                <label class="mr-2">Search Room:</label>
                <input type="text" name="search" value="${search}" 
                       placeholder="Enter room number..." class="form-control mr-3">
                
                <label class="mr-2">Filter Status:</label>
                <select name="status" class="form-control mr-3">
                    <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>All Status</option>
                    <option value="AVAILABLE" ${status == 'AVAILABLE' ? 'selected' : ''}>Available</option>
                    <option value="OCCUPIED" ${status == 'OCCUPIED' ? 'selected' : ''}>Occupied</option>
                    <option value="MAINTENANCE" ${status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                    <option value="DIRTY" ${status == 'DIRTY' ? 'selected' : ''}>Dirty</option>
                </select>
                
                <button type="submit" class="btn btn-primary">Filter</button>
            </form>
        </div>
    </div>
    
    <!-- Room Status Table -->
    <div class="table-container">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Room Number</th>
                    <th>Room Type</th>
                    <th>Current Status</th>
                    <th>Change Status</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="room" items="${rooms}">
                    <tr>
                        <td>${room.id}</td>
                        <td>${room.roomNumber}</td>
                        <td>${room.roomTypeName}</td>
                        <td>
                            <span class="badge badge-${room.status == 'AVAILABLE' ? 'success' : 
                                                      room.status == 'OCCUPIED' ? 'danger' : 
                                                      room.status == 'DIRTY' ? 'warning' : 'info'}">
                                ${room.status}
                            </span>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/HouseKeeping" 
                                  class="form-inline">
                                <input type="hidden" name="roomId" value="${room.id}" />
                                <select name="newStatus" class="form-control form-control-sm mr-2">
                                    <option value="">Select Status</option>
                                    <option value="AVAILABLE" ${room.status == 'AVAILABLE' ? 'selected' : ''}>Available</option>
                                    <option value="OCCUPIED" ${room.status == 'OCCUPIED' ? 'selected' : ''}>Occupied</option>
                                    <option value="MAINTENANCE" ${room.status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                                    <option value="DIRTY" ${room.status == 'DIRTY' ? 'selected' : ''}>Dirty</option>
                                </select>
                                <button type="submit" class="btn btn-sm btn-primary">Update</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty rooms}">
                    <tr>
                        <td colspan="5" class="text-center py-4">No rooms found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>