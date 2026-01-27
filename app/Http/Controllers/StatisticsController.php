<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests;
use App\BorrowLog;
use Yajra\Datatables\Facades\Datatables;
use Yajra\Datatables\Html\Builder;

class StatisticsController extends Controller
{
    public function index(Request $request, Builder $htmlBuilder)
    {
        if ($request->ajax()) {
            $stats = \DB::table('borrow_logs')
                ->join('books', 'books.id', '=', 'borrow_logs.book_id')
                ->join('users', 'users.id', '=', 'borrow_logs.user_id')
                ->select([
                    'borrow_logs.id',
                    'books.title as book_title',
                    'users.name as user_name',
                    'borrow_logs.created_at',
                    'borrow_logs.updated_at',
                    'borrow_logs.is_returned'
                ]);

            // Logika Filter Status
            if ($request->get('status') == 'returned') {
                $stats->where('is_returned', 1);
            } elseif ($request->get('status') == 'not-returned') {
                $stats->where('is_returned', 0);
            }

            return Datatables::of($stats)
                ->addColumn('returned_at', function($stat) {
                    if ($stat->is_returned) {
                        return date('d/m/Y H:i', strtotime($stat->updated_at));
                    }
                    return "Masih dipinjam";
                })
                // PENTING: Agar Search Judul Buku Berhasil di PostgreSQL
                ->filterColumn('book_title', function($query, $keyword) {
                    $query->where('books.title', 'ilike', "%$keyword%");
                })
                // PENTING: Agar Search Nama Peminjam Berhasil di PostgreSQL
                ->filterColumn('user_name', function($query, $keyword) {
                    $query->where('users.name', 'ilike', "%$keyword%");
                })
                ->make(true);
        }

        $html = $htmlBuilder
            ->addColumn(['data' => 'book_title', 'name'=>'books.title', 'title'=>'Judul'])
            ->addColumn(['data' => 'user_name', 'name'=>'users.name', 'title'=>'Peminjam'])
            ->addColumn(['data' => 'created_at', 'name'=>'borrow_logs.created_at', 'title'=>'Tanggal Pinjam'])
            ->addColumn(['data' => 'returned_at', 'name'=>'returned_at', 'title'=>'Tanggal Kembali', 
                         'orderable'=>false, 'searchable'=>false]);

        return view('statistics.index')->with(compact('html'));
    }
}