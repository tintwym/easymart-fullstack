<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up(): void
    {
        Schema::create('listings', function (Blueprint $table) {
            $table->ulid('id')->primary(); // Listing's own ID

            // Change this to foreignId() to match users.id
            $table->foreignUlid('user_id')->constrained()->onDelete('cascade');

            // Only use foreignUlid if categories table actually uses ULIDs
            $table->foreignUlid('category_id')->constrained()->onDelete('cascade');

            $table->string('title');
            $table->text('description');
            $table->decimal('price', 10, 2);
            $table->string('condition');
            $table->string('image_path')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('listings');
    }
};
