<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests;
use Yajra\Datatables\Html\Builder;
use Yajra\Datatables\Datatables;
use App\Book;
use Laratrust\LaratrustFacade as Laratrust;

class GuestController extends Controller
{
    public function index(Request $request, Builder $htmlBuilder)
    {
        if ($request->ajax()) {
            // Gunakan Query Builder dengan Join agar sama stabilnya dengan BooksController
            $books = \DB::table('books')
                ->join('authors', 'authors.id', '=', 'books.author_id')
                ->select([
                    'books.id', 
                    'books.title', 
                    'books.amount', 
                    'authors.name as author_name'
                ]);

            return Datatables::of($books)
                ->addColumn('stock', function($book) {
                    // Mengambil stok dari model Book berdasarkan ID
                    return Book::find($book->id)->stock;
                })
                ->addColumn('action', function($book) {
                    if (Laratrust::hasRole('admin')) return '';
                    return '<a class="btn btn-xs btn-primary" href="'.route('guest.books.borrow', $book->id).'">Pinjam</a>';
                })
                // Gunakan ilike agar search judul tidak sensitif huruf besar/kecil
                ->filterColumn('title', function($query, $keyword) {
                    $query->where('books.title', 'ilike', "%$keyword%");
                })
                // Gunakan ilike untuk search nama penulis
                ->filterColumn('author.name', function($query, $keyword) {
                    $query->where('authors.name', 'ilike', "%$keyword%");
                })
                ->make(true);
        }

        $html = $htmlBuilder
            ->addColumn(['data' => 'title', 'name'=>'books.title', 'title'=>'Judul'])
            ->addColumn(['data' => 'stock', 'name'=>'stock', 'title'=>'Stok', 'orderable'=>false, 'searchable'=>false])
            ->addColumn(['data' => 'author_name', 'name'=>'authors.name', 'title'=>'Penulis'])
            ->addColumn(['data' => 'action', 'name'=>'action', 'title'=>'', 'orderable'=>false, 'searchable'=>false]);

        return view('guest.index')->with(compact('html'));
    }
}