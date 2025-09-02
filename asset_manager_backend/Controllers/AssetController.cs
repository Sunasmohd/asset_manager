using Microsoft.AspNetCore.Mvc;
using asset_manager_backend.Models;
using asset_manager_backend.Data;
using Microsoft.EntityFrameworkCore; 
using Microsoft.AspNetCore.Authorization;

namespace asset_manager_backend.Controllers
{
    [ApiController]
    [Route("assets")]
    [Authorize] 
    public class AssetsController : ControllerBase
    {
        private readonly AssetDbContext _context;

        public AssetsController(AssetDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")] 
        public async Task<IActionResult> Create([FromBody] Asset asset)
        {
            if (!ModelState.IsValid)
            {
                Console.WriteLine("Create failed: Invalid model state.");
                return BadRequest(ModelState);
            }

            _context.Assets.Add(asset);
            await _context.SaveChangesAsync();

            Console.WriteLine($"Asset created: ID={asset.Id}, Name={asset.Name}, Type={asset.Type}, Status={asset.Status}, PurchaseDate={asset.PurchaseDate}, AssignedTo={asset.AssignedTo}");
            return CreatedAtAction(nameof(GetById), new { id = asset.Id }, asset);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(
            int pageNumber = 1,
            string? status = null)
        {
            const int pageSize = 15;
            var query = _context.Assets.AsQueryable();

            if (!string.IsNullOrEmpty(status) && Enum.TryParse<AssetStatus>(status, true, out var parsedStatus))
            {
                query = query.Where(a => a.Status == parsedStatus);
            }

            var totalRecords = await query.CountAsync();
            var assets = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new
            {
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize,
                Data = assets
            });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var asset = await _context.Assets.FindAsync(id);
            if (asset == null)
            {
                Console.WriteLine($"GetById failed: Asset ID={id} not found.");
                return NotFound();
            }

            Console.WriteLine($"GetById: Found Asset ID={asset.Id}, Name={asset.Name}");
            return Ok(asset);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")] 
        public async Task<IActionResult> Update(int id, [FromBody] Asset updatedAsset)
        {
            var existing = await _context.Assets.FindAsync(id);
            if (existing == null)
            {
                Console.WriteLine($"Update failed: Asset ID={id} not found.");
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                Console.WriteLine("Update failed: Invalid model state.");
                return BadRequest(ModelState);
            }

            existing.Name = updatedAsset.Name;
            existing.Type = updatedAsset.Type;
            existing.PurchaseDate = updatedAsset.PurchaseDate;
            existing.AssignedTo = updatedAsset.AssignedTo;
            existing.Status = updatedAsset.Status;

            await _context.SaveChangesAsync();
            Console.WriteLine($"Asset updated: ID={existing.Id}, Name={existing.Name}, Type={existing.Type}, Status={existing.Status}, PurchaseDate={existing.PurchaseDate}, AssignedTo={existing.AssignedTo}");
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")] 
        public async Task<IActionResult> Delete(int id)
        {
            var asset = await _context.Assets.FindAsync(id);
            if (asset == null)
            {
                Console.WriteLine($"Delete failed: Asset ID={id} not found.");
                return NotFound();
            }

            _context.Assets.Remove(asset);
            await _context.SaveChangesAsync();
            Console.WriteLine($"Asset deleted: ID={asset.Id}, Name={asset.Name}");
            return NoContent();
        }
    }

}