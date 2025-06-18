<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/my-inspections">My Inspections</a></li>
            <li class="breadcrumb-item active">View Inspection</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Inspection Report #${inspection.id}</h1>
        <div>
            <button class="btn btn-primary" onclick="window.print()">
                <i class="fas fa-print"></i> Print Report
            </button>
            <a href="${pageContext.request.contextPath}/inspector/my-inspections" 
               class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>
    </div>
    
    <!-- Report Header -->
    <div class="card mb-4">
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <h4>Luxury Hotel</h4>
                    <p class="mb-1">Room Inspection Report</p>
                    <p class="mb-0">
                        <small>
                            Generated on: <fmt:formatDate value="${inspection.inspectionTime}" 
                                                         pattern="dd/MM/yyyy HH:mm:ss"/>
                        </small>
                    </p>
                </div>
                <div class="col-md-6 text-right">
                    <h5>Report #${inspection.id}</h5>
                    <p class="mb-1">
                        Status: 
                        <span class="badge badge-${inspection.status == 'COMPLETED' ? 'success' : 'warning'}">
                            ${inspection.status}
                        </span>
                    </p>
                    <c:if test="${inspection.status == 'COMPLETED'}">
                        <p class="mb-0">
                            <small>
                                Approved by: ${inspection.approver.fullName}<br>
                                On: <fmt:formatDate value="${inspection.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </small>
                        </p>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Guest & Reservation Info -->
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Guest Information</h5>
                </div>
                <div class="card-body">
                    <p><strong>Name:</strong> ${inspection.reservation.customerName}</p>
                    <p><strong>Email:</strong> ${inspection.reservation.customerEmail}</p>
                    <p><strong>Phone:</strong> ${inspection.reservation.customerPhone}</p>
                    <p class="mb-0"><strong>Booking ID:</strong> #${inspection.reservation.id}</p>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Stay Details</h5>
                </div>
                <div class="card-body">
                    <p><strong>Room:</strong> ${inspection.reservation.room.roomNumber} - 
                       ${inspection.reservation.room.roomTypeName}</p>
                    <p><strong>Check-in:</strong> 
                       <fmt:formatDate value="${inspection.reservation.checkIn}" pattern="dd/MM/yyyy"/></p>
                    <p><strong>Check-out:</strong> 
                       <fmt:formatDate value="${inspection.reservation.checkOut}" pattern="dd/MM/yyyy"/></p>
                    <p class="mb-0"><strong>Room Rate:</strong> 
                       <fmt:formatNumber value="${inspection.reservation.totalAmount}" pattern="#,##0"/>₫</p>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Inspection Details -->
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="mb-0">Inspection Summary</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <p><strong>Inspector:</strong> ${inspection.inspector.fullName}</p>
                    <p><strong>Inspection Date:</strong> 
                       <fmt:formatDate value="${inspection.inspectionTime}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>
                <div class="col-md-4">
                    <p><strong>Room Condition:</strong> 
                        <span class="room-condition-badge condition-${inspection.roomCondition.toLowerCase()}">
                            ${inspection.roomCondition}
                        </span>
                    </p>
                    <p><strong>Cleanliness Score:</strong> ${inspection.cleanlinessScore}/10</p>
                </div>
                <div class="col-md-4">
                    <p><strong>Total Additional Charges:</strong></p>
                    <h4 class="text-primary">
                        <fmt:formatNumber value="${inspection.totalCharges}" pattern="#,##0"/>₫
                    </h4>
                </div>
            </div>
            
            <c:if test="${not empty inspection.notes}">
                <hr>
                <p><strong>Inspector Notes:</strong></p>
                <p class="mb-0">${inspection.notes}</p>
            </c:if>
        </div>
    </div>
    
    <!-- Used Items -->
    <c:if test="${not empty inspection.inspectionItems}">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Minibar & Amenities Usage</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Item</th>
                                <th>Category</th>
                                <th class="text-center">Quantity</th>
                                <th class="text-right">Unit Price</th>
                                <th class="text-right">Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${inspection.inspectionItems}">
                                <tr>
                                    <td>
                                        ${item.itemName}
                                        <c:if test="${not empty item.notes}">
                                            <br><small class="text-muted">${item.notes}</small>
                                        </c:if>
                                    </td>
                                    <td>${item.itemCategory}</td>
                                    <td class="text-center">${item.quantity}</td>
                                    <td class="text-right">
                                        <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/>₫
                                    </td>
                                    <td class="text-right">
                                        <fmt:formatNumber value="${item.totalPrice}" pattern="#,##0"/>₫
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4" class="text-right">Subtotal:</th>
                                <th class="text-right">
                                    <fmt:formatNumber value="${inspection.totalItemCharges}" pattern="#,##0"/>₫
                                </th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </c:if>
    
    <!-- Damages -->
    <c:if test="${not empty inspection.roomDamages}">
        <div class="card mb-4">
            <div class="card-header bg-danger text-white">
                <h5 class="mb-0">Reported Damages</h5>
            </div>
            <div class="card-body">
                <c:forEach var="damage" items="${inspection.roomDamages}">
                    <div class="border rounded p-3 mb-3">
                        <div class="row">
                            <div class="col-md-8">
                                <h6>${damage.damageType} 
                                    <span class="badge badge-${damage.severity == 'SEVERE' ? 'danger' : 
                                                              damage.severity == 'MAJOR' ? 'warning' : 'info'}">
                                        ${damage.severity}
                                    </span>
                                </h6>
                                <p>${damage.description}</p>
                                <p class="mb-0">
                                    <strong>Estimated Repair Cost:</strong> 
                                    <span class="text-danger">
                                        <fmt:formatNumber value="${damage.estimatedCost}" pattern="#,##0"/>₫
                                    </span>
                                </p>
                            </div>
                            <div class="col-md-4 text-right">
                                <c:if test="${not empty damage.photoUrl}">
                                    <a href="${pageContext.request.contextPath}/uploads/${damage.photoUrl}" 
                                       target="_blank" class="btn btn-sm btn-info">
                                        <i class="fas fa-image"></i> View Photo
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <div class="text-right">
                    <h5>Total Damage Charges: 
                        <span class="text-danger">
                            <fmt:formatNumber value="${inspection.totalDamageCharges}" pattern="#,##0"/>₫
                        </span>
                    </h5>
                </div>
            </div>
        </div>
    </c:if>
    
    <!-- Final Summary -->
    <div class="card bg-light">
        <div class="card-body">
            <h4 class="text-center mb-4">Final Charges Summary</h4>
            <div class="row">
                <div class="col-md-6 offset-md-3">
                    <table class="table table-borderless">
                        <tr>
                            <td>Room Charges:</td>
                            <td class="text-right">
                                <fmt:formatNumber value="${inspection.reservation.totalAmount}" pattern="#,##0"/>₫
                            </td>
                        </tr>
                        <tr>
                            <td>Minibar/Amenities:</td>
                            <td class="text-right">
                                <fmt:formatNumber value="${inspection.totalItemCharges}" pattern="#,##0"/>₫
                            </td>
                        </tr>
                        <tr>
                            <td>Damages:</td>
                            <td class="text-right text-danger">
                                <fmt:formatNumber value="${inspection.totalDamageCharges}" pattern="#,##0"/>₫
                            </td>
                        </tr>
                        <tr class="border-top">
                            <td><h5>Total Amount Due:</h5></td>
                            <td class="text-right">
                                <h5 class="text-primary">
                                    <fmt:formatNumber value="${inspection.reservation.totalAmount + inspection.totalCharges}" 
                                                    pattern="#,##0"/>₫
                                </h5>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
@media print {
    .btn, .breadcrumb, header, aside {
        display: none !important;
    }
    
    .main-content {
        margin: 0 !important;
        padding: 20px !important;
    }
    
    .card {
        break-inside: avoid;
        page-break-inside: avoid;
    }
}
</style>