<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Management - GitHub Style</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif;
            background-color: #0d1117;
            color: #e6edf3;
            line-height: 1.5;
        }

        .container-fluid {
            max-width: 1280px;
            margin: 0 auto;
            padding: 24px;
        }

        /* Breadcrumb Styling */
        .breadcrumb-nav {
            margin-bottom: 24px;
        }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #7d8590;
        }

        .breadcrumb a {
            color: #58a6ff;
            text-decoration: none;
            transition: color 0.2s;
        }

        .breadcrumb a:hover {
            color: #79c0ff;
            text-decoration: underline;
        }

        .breadcrumb-separator {
            color: #6e7681;
        }

        /* Alert Styling */
        .alert {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px;
            margin-bottom: 16px;
            border-radius: 6px;
            border: 1px solid;
            position: relative;
            animation: slideIn 0.3s ease-out;
        }

        .alert-success {
            background-color: #0f2419;
            border-color: #2ea043;
            color: #56d364;
        }

        .alert-danger {
            background-color: #21262d;
            border-color: #f85149;
            color: #f85149;
        }

        .alert-close {
            position: absolute;
            right: 12px;
            top: 12px;
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            padding: 4px;
            border-radius: 3px;
            transition: background-color 0.2s;
        }

        .alert-close:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }

        /* Header Section */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid #30363d;
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: #f0f6fc;
        }

        .header-actions {
            display: flex;
            gap: 8px;
        }

        /* Filter Card */
        .filter-card {
            background-color: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 16px;
            margin-bottom: 16px;
        }

        .filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-label {
            font-size: 12px;
            font-weight: 600;
            color: #f0f6fc;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-control {
            background-color: #21262d;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 8px 12px;
            color: #e6edf3;
            font-size: 14px;
            transition: border-color 0.2s, box-shadow 0.2s;
            min-width: 180px;
        }

        .form-control:focus {
            outline: none;
            border-color: #58a6ff;
            box-shadow: 0 0 0 3px rgba(88, 166, 255, 0.3);
        }

        .form-control::placeholder {
            color: #6e7681;
        }

        /* Button Styles */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            font-size: 14px;
            font-weight: 500;
            border-radius: 6px;
            border: 1px solid;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .btn-primary {
            background-color: #238636;
            border-color: #238636;
            color: #ffffff;
        }

        .btn-primary:hover {
            background-color: #2ea043;
        }

        .btn-secondary {
            background-color: #21262d;
            border-color: #30363d;
            color: #f0f6fc;
        }

        .btn-secondary:hover {
            background-color: #30363d;
        }

        .btn-success {
            background-color: #238636;
            border-color: #238636;
            color: #ffffff;
        }

        .btn-danger {
            background-color: #da3633;
            border-color: #da3633;
            color: #ffffff;
        }

        .btn-sm {
            padding: 4px 8px;
            font-size: 12px;
        }

        /* Table Styling */
        .table-container {
            background-color: #0d1117;
            border: 1px solid #30363d;
            border-radius: 6px;
            overflow: hidden;
        }

        .table-header {
            display: flex;
            justify-content: between;
            align-items: center;
            padding: 16px;
            background-color: #161b22;
            border-bottom: 1px solid #30363d;
        }

        .records-info {
            font-size: 12px;
            color: #7d8590;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th {
            background-color: #161b22;
            padding: 12px 16px;
            text-align: left;
            font-size: 12px;
            font-weight: 600;
            color: #f0f6fc;
            border-bottom: 1px solid #30363d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .table td {
            padding: 12px 16px;
            border-bottom: 1px solid #21262d;
            font-size: 14px;
            vertical-align: middle;
        }

        .table tbody tr {
            transition: background-color 0.2s;
        }

        .table tbody tr:hover {
            background-color: #161b22;
        }

        .table tbody tr:last-child td {
            border-bottom: none;
        }

        /* Badge Styling */
        .badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 8px;
            font-size: 12px;
            font-weight: 500;
            border-radius: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-pending {
            background-color: #bb800940;
            color: #bb8009;
            border: 1px solid #bb800950;
        }

        .badge-confirmed {
            background-color: #2ea04340;
            color: #2ea043;
            border: 1px solid #2ea04350;
        }

        .badge-checked-in {
            background-color: #58a6ff40;
            color: #58a6ff;
            border: 1px solid #58a6ff50;
        }

        .badge-checked-out {
            background-color: #6e768140;
            color: #8b949e;
            border: 1px solid #6e768150;
        }

        .badge-cancelled {
            background-color: #f8514940;
            color: #f85149;
            border: 1px solid #f8514950;
        }

        .badge-info {
            background-color: #1f6feb40;
            color: #79c0ff;
            border: 1px solid #1f6feb50;
        }

        /* Action Buttons */
        .btn-group {
            display: flex;
            gap: 4px;
        }

        .btn-action {
            padding: 6px 8px;
            border-radius: 4px;
            border: 1px solid #30363d;
            background-color: #21262d;
            color: #e6edf3;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-action:hover {
            background-color: #30363d;
        }

        .btn-action.btn-info {
            color: #58a6ff;
        }

        .btn-action.btn-warning {
            color: #d29922;
        }

        .btn-action.btn-danger {
            color: #f85149;
        }

        .btn-action.btn-success {
            color: #56d364;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 4px;
            padding: 16px;
            background-color: #0d1117;
        }

        .page-item {
            display: flex;
        }

        .page-link {
            padding: 8px 12px;
            color: #58a6ff;
            text-decoration: none;
            border: 1px solid #30363d;
            border-radius: 6px;
            transition: all 0.2s;
        }

        .page-link:hover {
            background-color: #21262d;
            color: #79c0ff;
        }

        .page-item.active .page-link {
            background-color: #1f6feb;
            border-color: #1f6feb;
            color: #ffffff;
        }

        .page-item.disabled .page-link {
            color: #6e7681;
            cursor: not-allowed;
            background-color: #0d1117;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: #7d8590;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 16px;
            color: #30363d;
        }

        .empty-state h3 {
            font-size: 20px;
            margin-bottom: 8px;
            color: #f0f6fc;
        }

        .empty-state p {
            margin-bottom: 24px;
        }

        /* Modal Styling */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(1, 4, 9, 0.8);
            z-index: 1000;
            animation: fadeIn 0.3s ease-out;
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-dialog {
            background-color: #21262d;
            border: 1px solid #30363d;
            border-radius: 12px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 16px 32px rgba(1, 4, 9, 0.85);
            animation: slideUp 0.3s ease-out;
        }

        .modal-header {
            padding: 20px 24px 16px;
            border-bottom: 1px solid #30363d;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 600;
            color: #f0f6fc;
        }

        .modal-close {
            background: none;
            border: none;
            color: #7d8590;
            cursor: pointer;
            padding: 8px;
            border-radius: 6px;
            transition: all 0.2s;
        }

        .modal-close:hover {
            background-color: #30363d;
            color: #f0f6fc;
        }

        .modal-body {
            padding: 20px 24px;
        }

        .modal-body p {
            margin-bottom: 12px;
            color: #e6edf3;
        }

        .modal-body .text-warning {
            color: #d29922;
            font-size: 14px;
        }

        .modal-footer {
            padding: 16px 24px 20px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
        }

        /* Animations */
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .container-fluid {
                padding: 16px;
            }

            .filter-form {
                flex-direction: column;
                align-items: stretch;
            }

            .form-control {
                min-width: auto;
            }

            .page-header {
                flex-direction: column;
                gap: 16px;
                align-items: flex-start;
            }

            .header-actions {
                width: 100%;
                justify-content: flex-start;
            }

            .table-container {
                overflow-x: auto;
            }

            .table {
                min-width: 800px;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Breadcrumb -->
        <nav class="breadcrumb-nav" aria-label="breadcrumb">
            <div class="breadcrumb">
                <a href="/admin-dashboard">
                    <i class="fas fa-home"></i> Dashboard
                </a>
                <span class="breadcrumb-separator">/</span>
                <span>Booking Management</span>
            </div>
        </nav>
        
        <!-- Alert Messages -->
        <div id="alertContainer">
            <!-- Success Alert Example -->
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <span>Booking has been successfully updated!</span>
                <button class="alert-close" onclick="closeAlert(this)">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </div>

        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-calendar-alt"></i>
                Booking Management
            </h1>
            <div class="header-actions">
                <button class="btn btn-secondary" id="viewCancelledBtn">
                    <i class="fas fa-ban"></i> View Cancelled
                </button>
                <button class="btn btn-success">
                    <i class="fas fa-plus"></i> New Booking
                </button>
            </div>
        </div>
        
        <!-- Filters and Search -->
        <div class="filter-card">
            <form class="filter-form">
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" name="status">
                        <option value="ALL">All Status</option>
                        <option value="PENDING">Pending</option>
                        <option value="CONFIRMED">Confirmed</option>
                        <option value="CHECKED_IN">Checked In</option>
                        <option value="CHECKED_OUT">Checked Out</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Check-in Date</label>
                    <input type="date" class="form-control" name="fromDate">
                </div>
                
                <div class="form-group">
                    <label class="form-label">To</label>
                    <input type="date" class="form-control" name="toDate">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Search</label>
                    <input type="text" class="form-control" placeholder="Booking ID, guest name..." name="search">
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                </div>
                
                <div class="form-group">
                    <button type="button" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Clear
                    </button>
                </div>
            </form>
        </div>
        
        <!-- Bookings Table -->
        <div class="table-container">
            <div class="table-header">
                <div class="records-info">
                    Showing 1 - 5 of 25 bookings
                </div>
            </div>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Booking ID</th>
                        <th>Guest Name</th>
                        <th>Room</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Guests</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                        <th>Created Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="bookingTableBody">
                    <tr>
                        <td>1</td>
                        <td>BK001</td>
                        <td>John Doe</td>
                        <td>101</td>
                        <td>23/06/2025</td>
                        <td>25/06/2025</td>
                        <td><span class="badge badge-info">2</span></td>
                        <td>$250.00</td>
                        <td><span class="badge badge-confirmed">Confirmed</span></td>
                        <td>20/06/2025</td>
                        <td>
                            <div class="btn-group">
                                <button class="btn-action btn-info" title="View">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn-action btn-warning" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn-action btn-danger" title="Cancel" onclick="confirmCancel(1, 'BK001')">
                                    <i class="fas fa-ban"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td>BK002</td>
                        <td>Jane Smith</td>
                        <td>205</td>
                        <td>24/06/2025</td>
                        <td>27/06/2025</td>
                        <td><span class="badge badge-info">1</span></td>
                        <td>$375.00</td>
                        <td><span class="badge badge-pending">Pending</span></td>
                        <td>22/06/2025</td>
                        <td>
                            <div class="btn-group">
                                <button class="btn-action btn-info" title="View">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn-action btn-warning" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn-action btn-danger" title="Cancel" onclick="confirmCancel(2, 'BK002')">
                                    <i class="fas fa-ban"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>3</td>
                        <td>BK003</td>
                        <td>Michael Johnson</td>
                        <td>301</td>
                        <td>25/06/2025</td>
                        <td>30/06/2025</td>
                        <td><span class="badge badge-info">3</span></td>
                        <td>$625.00</td>
                        <td><span class="badge badge-checked-in">Checked In</span></td>
                        <td>18/06/2025</td>
                        <td>
                            <div class="btn-group">
                                <button class="btn-action btn-info" title="View">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn-action btn-warning" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn-action btn-danger" title="Cancel" onclick="confirmCancel(3, 'BK003')">
                                    <i class="fas fa-ban"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
            
            <!-- Pagination -->
            <nav class="pagination" aria-label="Page navigation">
                <div class="page-item disabled">
                    <span class="page-link">Previous</span>
                </div>
                <div class="page-item active">
                    <span class="page-link">1</span>
                </div>
                <div class="page-item">
                    <a class="page-link" href="#" onclick="goToPage(2)">2</a>
                </div>
                <div class="page-item">
                    <a class="page-link" href="#" onclick="goToPage(3)">3</a>
                </div>
                <div class="page-item">
                    <a class="page-link" href="#" onclick="goToPage(2)">Next</a>
                </div>
            </nav>
        </div>
    </div>

    <!-- Cancel Confirmation Modal -->
    <div class="modal" id="cancelModal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Cancel</h5>
                <button class="modal-close" onclick="closeModal('cancelModal')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to cancel booking "<span id="cancelBookingId"></span>"?</p>
                <p class="text-warning">This action will move the booking to cancelled list.</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal('cancelModal')">Cancel</button>
                <button class="btn btn-danger" id="cancelConfirmBtn">Cancel Booking</button>
            </div>
        </div>
    </div>

    <!-- Restore Confirmation Modal -->
    <div class="modal" id="restoreModal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Restore</h5>
                <button class="modal-close" onclick="closeModal('restoreModal')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to restore booking "<span id="restoreBookingId"></span>"?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal('restoreModal')">Cancel</button>
                <button class="btn btn-success" id="restoreConfirmBtn">Restore</button>
            </div>
        </div>
    </div>

    <script>
        // Modal functionality
        function confirmCancel(bookingId, bookingCode) {
            document.getElementById('cancelBookingId').textContent = bookingCode;
            document.getElementById('cancelConfirmBtn').onclick = function() {
                // Handle cancel booking logic here
                console.log('Cancelling booking:', bookingId);
                closeModal('cancelModal');
                showAlert('Booking has been cancelled successfully!', 'success');
            };
            showModal('cancelModal');
        }

        function confirmRestore(bookingId, bookingCode) {
            document.getElementById('restoreBookingId').textContent = bookingCode;
            document.getElementById('restoreConfirmBtn').onclick = function() {
                // Handle restore booking logic here
                console.log('Restoring booking:', bookingId);
                closeModal('restoreModal');
                showAlert('Booking has been restored successfully!', 'success');
            };
            showModal('restoreModal');
        }

        function showModal(modalId) {
            document.getElementById(modalId).classList.add('show');
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('show');
        }

        // Alert functionality
        function showAlert(message, type = 'success') {
            const alertContainer = document.getElementById('alertContainer');
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            const iconClass = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
            
            const alertHtml = `
                <div class="alert ${alertClass}">
                    <i class="fas ${iconClass}"></i>
                    <span>${message}</span>
                    <button class="alert-close" onclick="closeAlert(this)">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `;
            
            alertContainer.innerHTML = alertHtml;
            
            // Auto close after 5 seconds
            setTimeout(() => {
                const alert = alertContainer.querySelector('.alert');
                if (alert) {
                    closeAlert(alert.querySelector('.alert-close'));
                }
            }, 5000);
        }

        function closeAlert(button) {
            const alert = button.closest('.alert');
            alert.style.animation = 'slideIn 0.3s ease-out reverse';
            setTimeout(() => {
                alert.remove();
            }, 300);
        }

        // Pagination functionality
        function goToPage(page) {
            console.log('Going to page:', page);
            // Handle pagination logic here
        }

        // Form functionality
        document.querySelector('.filter-form').addEventListener('submit', function(e) {
            e.preventDefault();
            // Handle form submission logic here
            console.log('Filtering bookings...');
        });

        // View toggle functionality
        document.getElementById('viewCancelledBtn').addEventListener('click', function() {
            // Toggle to cancelled view
            console.log('Switching to cancelled bookings view');
        });

        // Close modal when clicking outside
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('modal')) {
                closeModal(e.target.id);
            }
        });

        // Keyboard navigation
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const openModal = document.querySelector('.modal.show');
                if (openModal) {
                    closeModal(openModal.id);
                }
            }
        });

        // Clear alerts on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Clear existing alerts after 3 seconds
            setTimeout(() => {
                const alerts = document.querySelectorAll('.alert');
                alerts.forEach(alert => {
                    const closeBtn = alert.querySelector('.alert-close');
                    if (closeBtn) {
                        closeAlert(closeBtn);
                    }
                });
            }, 3000);
        });
    </script>
</body>
</html>
